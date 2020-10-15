// SPDX-License-Identifier: WTFPL
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./uniswapv2/interfaces/IUniswapV2Pair.sol";
import "./uniswapv2/interfaces/IUniswapV2Factory.sol";
import "./tokens/IFAVault.sol";
import "./calculators/ICalculator.sol";
import "./components/IFAPool.sol";
import "./components/IFABank.sol";
import "./strategies/CreateIFA.sol";

// Query data related to ifa.
// This contract is owned by Timelock.
contract IFADataBoard is Ownable {

    IFAMaster public ifaMaster;

    constructor(IFAMaster _ifaMaster) public {
        ifaMaster = _ifaMaster;
    }

    function getCalculatorStat(uint256 _poolId) public view returns (uint256, uint256, uint256) {
        ICalculator calculator;
        (,, calculator) = IFABank(ifaMaster.bank()).poolMap(_poolId);
        uint256 rate = calculator.rate();
        uint256 minimumLTV = calculator.minimumLTV();
        uint256 maximumLTV = calculator.maximumLTV();
        return (rate, minimumLTV, maximumLTV);
    }

    function getPendingReward(uint256 _poolId, uint256 _index) public view returns (uint256) {
        IFAVault vault;
        (, vault,) = IFAPool(ifaMaster.pool()).poolMap(_poolId);
        return vault.getPendingReward(msg.sender, _index);
    }

    // get APY * 100
    function getAPY(uint256 _poolId, address _token, bool _isLPToken) public view returns (uint256) {
        (, IFAVault vault,) = IFAPool(ifaMaster.pool()).poolMap(_poolId);

        uint256 MK_STRATEGY_CREATE_IFA = 0;
        CreateIFA createIFA = CreateIFA(ifaMaster.strategyByKey(MK_STRATEGY_CREATE_IFA));
        (uint256 allocPoint,) = createIFA.poolMap(address(vault));
        uint256 totalAlloc = createIFA.totalAllocPoint();

        if (totalAlloc == 0) {
            return 0;
        }

        uint256 vaultSupply = vault.totalSupply();


        uint256 factor = 1;
        // 1 IFA per block
        if (vaultSupply == 0) {
            // Assume $1 is put in.
            return getIFAPrice() * factor * 5760 * 100 * allocPoint / totalAlloc / 1e6;
        }

        // 2250000 is the estimated yearly block number of ethereum.
        // 1e18 comes from vaultSupply.
        if (_isLPToken) {
            uint256 lpPrice = getEthLpPrice(_token);
            if (lpPrice == 0) {
                return 0;
            }

            return getIFAPrice() * factor * 2250000 * 100 * allocPoint * 1e18 / totalAlloc / lpPrice / vaultSupply;
        } else {
            uint256 tokenPrice = getTokenPrice(_token);
            if (tokenPrice == 0) {
                return 0;
            }

            return getIFAPrice() * factor * 2250000 * 100 * allocPoint * 1e18 / totalAlloc / tokenPrice / vaultSupply;
        }
    }

    // return user loan record size.
    function getUserLoanLength(address _who) public view returns (uint256) {
        return IFABank(ifaMaster.bank()).getLoanListLength(_who);
    }

    // return loan info (loanId,principal, interest, lockedAmount, time, rate, maximumLTV)
    function getUserLoan(address _who, uint256 _index) public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 poolId;
        uint256 loanId;
        (poolId, loanId) = IFABank(ifaMaster.bank()).loanList(_who, _index);

        ICalculator calculator;
        (,, calculator) = IFABank(ifaMaster.bank()).poolMap(poolId);

        uint256 lockedAmount = calculator.getLoanLockedAmount(loanId);
        uint256 principal = calculator.getLoanPrincipal(loanId);
        uint256 interest = calculator.getLoanInterest(loanId);
        uint256 time = calculator.getLoanTime(loanId);
        uint256 rate = calculator.getLoanRate(loanId);
        uint256 maximumLTV = calculator.getLoanMaximumLTV(loanId);

        return (loanId, principal, interest, lockedAmount, time, rate, maximumLTV);
    }

    function getEthLpPrice(address _token) public view returns (uint256) {
        IUniswapV2Factory factory = IUniswapV2Factory(ifaMaster.uniswapV2Factory());
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(_token, ifaMaster.wETH()));
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        if (pair.token0() == _token) {
            return reserve1 * getEthPrice() * 2 / pair.totalSupply();
        } else {
            return reserve0 * getEthPrice() * 2 / pair.totalSupply();
        }
    }

    // Return the 6 digit price of eth on uniswap.
    function getEthPrice() public view returns (uint256) {
        IUniswapV2Factory factory = IUniswapV2Factory(ifaMaster.uniswapV2Factory());
        IUniswapV2Pair ethUSDTPair = IUniswapV2Pair(factory.getPair(ifaMaster.wETH(), ifaMaster.usd()));
        require(address(ethUSDTPair) != address(0), "ethUSDTPair need set by owner");
        (uint reserve0, uint reserve1,) = ethUSDTPair.getReserves();
        // USDT has 6 digits and WETH has 18 digits.
        // To get 6 digits after floating point, we need 1e18.
        if (ethUSDTPair.token0() == ifaMaster.wETH()) {
            return reserve1 * 1e18 / reserve0;
        } else {
            return reserve0 * 1e18 / reserve1;
        }
    }

    // Return the 6 digit price of ifa on uniswap.
    function getIFAPrice() public view returns (uint256) {
        return getTokenPrice(ifaMaster.ifa());
    }

    // Return the 6 digit price of any token on uniswap.
    function getTokenPrice(address _token) public view returns (uint256) {
        if (_token == ifaMaster.wETH()) {
            return getEthPrice();
        }

        IUniswapV2Factory factory = IUniswapV2Factory(ifaMaster.uniswapV2Factory());
        IUniswapV2Pair tokenETHPair = IUniswapV2Pair(factory.getPair(_token, ifaMaster.wETH()));
        require(address(tokenETHPair) != address(0), "tokenETHPair need set by owner");
        (uint reserve0, uint reserve1,) = tokenETHPair.getReserves();

        if (reserve0 == 0 || reserve1 == 0) {
            return 0;
        }

        // For 18 digits tokens, we will return 6 digits price.
        if (tokenETHPair.token0() == _token) {
            return getEthPrice() * reserve1 / reserve0;
        } else {
            return getEthPrice() * reserve0 / reserve1;
        }
    }
}

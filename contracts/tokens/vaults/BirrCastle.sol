// SPDX-License-Identifier: WTFPL
pragma solidity 0.6.12;

import "../IFAVault.sol";

// Owned by Timelock
contract BirrCastle is IFAVault {
    // seed DAI, harvest IFA, borrow iUSD
    constructor (
        IFAMaster _ifaMaster,
        IStrategy _createIFA
    ) IFAVault(_ifaMaster, "Birr Castle", "Boil") public  {
        IStrategy[] memory strategies = new IStrategy[](1);
        strategies[0] = _createIFA;
        setStrategies(strategies);
    }
}

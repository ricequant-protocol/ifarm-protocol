
// Contract address
// current_net = 'test'
current_net = 'mainnet'

// develop address
const testNetContract = {
    'mdex': {
        'factory': "0x223a74cab41a9AE8ca339c7F0c1a99E6AF7D8d6C",
        'router': "0x61b305165D158bee6e78805530DaDcBf42B858B9",
    },
    'itokens': {
        'rETH': "0x8c5677b4FEaff533daB4638D7BEd7FFc972c4E84",
        'rBTC': "0x7d1E2717322a9155242A1853a28A0148a10Efb61",
        'rUSD': "0x4d97D3bf4A0bD87F9DEBb16873BdfE24127C9307",
    },
    'tokens': {
        'HUSD': '0x8Dd66eefEF4B503EB556b1f50880Cc04416B916B',
        'HBTC': '0x1D8684e6CdD65383AfFd3D5CF8263fCdA5001F13',
        'HETH': '0xfeB76Ae65c11B363Bd452afb4A7eC59925848656',
        'WHT': '0x9C6eb346f2105673eefaF2E8d0d6AFBf23b27005',
        'RICE': '0x58eABbc7438bd1e025868bD75d55aDEe1c1A1995',
        'USDT': '0x04F535663110A392A6504839BEeD34E019FdB4E0'
    },
    'lpToken': {
        "rUSD_HUSD": '0xEAB31C7dBd11c28E2D777075640a73e5E7d7FdD6',
        "rBTC_HBTC": '0xb4dE9b60E6Aec01c4CfBBD8E2e7DfE6de2A7B504',
        "rETH_HETH": '0x1f8E6639b3B77C6aaAe8169F80EAfe2146658F79',
        "RICE_rUSD": '0xA96fA13F2d1DD264993682967c11e1698481BD77',
        "RICE_rBTC": '0xbDF76FBdb106158Dc16B786d77684746C2666858',
        "RICE_rETH": '0xCaC2EEDE0C4A31ABa9707daCBDc2fBff310e4348'
    }
}

// ropsten address
const mainNetContract = {
    'mdex': {
        'factory': "0xb0b670fc1F7724119963018DB0BfA86aDb22d941",
        'router': "0xED7d5F38C79115ca12fe6C0041abb22F0A06C300",
    },
    'itokens': {
        'rETH': "0x8c5677b4FEaff533daB4638D7BEd7FFc972c4E84",
        'rBTC': "0x7d1E2717322a9155242A1853a28A0148a10Efb61",
        'rUSD': "0x4d97D3bf4A0bD87F9DEBb16873BdfE24127C9307",
    },
    'tokens': {
        // HUSD address -> USDT address
        'HUSD': '0xa71EdC38d189767582C38A3145b5873052c3e47a',
        'HBTC': '0x66a79D23E58475D2738179Ca52cd0b41d73f0BEa',
        'HETH': '0x64FF637fB478863B7468bc97D30a5bF3A428a1fD',
        'WHT': '0x5545153CCFcA01fbd7Dd11C0b23ba694D9509A6F',
        'RICE': '0x311F91e8683d7030E26C42377CCA9C673E81c9B4',
        'USDT': '0xa71EdC38d189767582C38A3145b5873052c3e47a'
    },
    'lpToken': {
        // HUSD address -> USDT address
        // "rUSD_HUSD": '0xa6a72e904B67dF314Dd08b17D94D9c36cF0F8eFA',
        "rUSD_USDT": '0x52ea88EaF565EB7842754987291E2feaCeB61b94',
        "rBTC_HBTC": '0x78fab4c35b1c0d073a983a72d00c39f7182a69e1',
        "rETH_HETH": '0x13e4d5f5567a6d4e29fa9b72d554d37e116ca54a',
        'RICE_rUSD':'0x1e06ac5725390e5f7ef4d005a51982d63a0d8b17',
        'RICE_rBTC':'0x15c4e63bb78e824540aaab17a93d11053b28fd27',
        'RICE_rETH':'0x7a41ca9c0c5258def8acf386e768c774008fcc92',
    }
}

let net_items = {
    'test': testNetContract,
    'mainnet': mainNetContract,
}

let getDeployedContract = () => {
    return net_items[current_net]
}

module.exports = {
    'getDeployedContract': getDeployedContract
}
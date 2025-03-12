# Erc20-TokenTools


```solidity
    struct TokenInfo {
        address tokenAddress;
        bool isERC20;
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
    }

   function getTokenInfo(
        address[] memory tokenAddresses
    ) external view returns (TokenInfo[] memory);
```

可以批量获取token信息，包括token的名称、符号、精度、总供应量、合约地址等信息。

同时 会 根据 token 信息 判断是否 符合 ERC20 标准




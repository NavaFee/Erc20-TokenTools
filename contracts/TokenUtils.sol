// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

contract TokenUtils {
    address internal test_address = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045; // v神地址

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
    ) external view returns (TokenInfo[] memory) {
        TokenInfo[] memory tokens = new TokenInfo[](tokenAddresses.length);

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            address token = tokenAddresses[i];

            if (token.code.length == 0) {
                tokens[i] = TokenInfo(token, false, "", "", 0, 0);
                continue;
            }

            // 进行静态调用，避免出错

            (bool successName, bytes memory dataName) = token.staticcall(
                abi.encodeWithSignature("name()")
            );

            (bool successSymbol, bytes memory dataSymbol) = token.staticcall(
                abi.encodeWithSignature("symbol()")
            );

            (bool successDecimals, bytes memory dataDecimals) = token
                .staticcall(abi.encodeWithSignature("decimals()"));

            (bool successTotalSupply, bytes memory dataTotalSupply) = token
                .staticcall(abi.encodeWithSignature("totalSupply()"));

            (bool successBalance, bytes memory dataBalance) = token.staticcall(
                abi.encodeWithSignature("balanceOf(address)", test_address)
            );

            bool isERC20 = successBalance &&
                successTotalSupply &&
                successSymbol &&
                successName &&
                successDecimals;

            tokens[i] = TokenInfo(
                token,
                isERC20,
                successName ? abi.decode(dataName, (string)) : "",
                successSymbol ? abi.decode(dataSymbol, (string)) : "",
                successDecimals ? abi.decode(dataDecimals, (uint8)) : 0,
                successTotalSupply ? abi.decode(dataTotalSupply, (uint256)) : 0
            );
        }

        return tokens;
    }
}

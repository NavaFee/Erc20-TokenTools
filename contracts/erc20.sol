// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract ERC20 {
    function name() external view returns (string memory) {
        return "ERC20";
    }

    function symbol() external view returns (string memory) {
        return "ERC20";
    }

    function decimals() external view returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint256) {
        return 1000000000000000000;
    }
}

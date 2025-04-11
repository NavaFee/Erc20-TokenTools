// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract BadToken {
    // 故意实现一个有问题的balanceOf函数
    function balanceOf(address) external pure returns (uint256) {
        revert("Balance query failed");
    }

    function name() external pure returns (string memory) {
        return "Bad Token";
    }

    function symbol() external pure returns (string memory) {
        return "BAD";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }
}

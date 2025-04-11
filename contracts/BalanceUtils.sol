// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract BalanceUtils {
    struct BalanceReq {
        address owner;
        address[] tokenAddresses;
    }

    struct BalanceResp {
        address user;
        address[] tokenAddresses;
        uint256[] balances;
        uint256 mainBalance;
    }

    function getBatchTokensBalance(
        BalanceReq[] memory req
    ) external view returns (BalanceResp[] memory) {
        BalanceResp[] memory responses = new BalanceResp[](req.length);

        for (uint256 i = 0; i < req.length; i++) {
            address owner = req[i].owner;
            address[] memory tokens = req[i].tokenAddresses;
            uint256[] memory balances = new uint256[](tokens.length);

            for (uint256 j = 0; j < tokens.length; j++) {
                try IERC20(tokens[j]).balanceOf(owner) returns (
                    uint256 balance
                ) {
                    balances[j] = balance;
                } catch {
                    balances[j] = 0;
                }
            }

            uint256 mainBalance;
            try this.getBalance(owner) returns (uint256 balance) {
                mainBalance = balance;
            } catch {
                mainBalance = 0;
            }

            responses[i] = BalanceResp({
                user: owner,
                tokenAddresses: tokens,
                balances: balances,
                mainBalance: mainBalance
            });
        }

        return responses;
    }

    function getBalance(address account) external view returns (uint256) {
        return account.balance;
    }
}

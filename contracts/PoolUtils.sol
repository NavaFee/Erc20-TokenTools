// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract PoolUtils {
    struct Pair {
        address token0;
        address token1;
        uint8 decimal0;
        uint8 decimal1;
    }

    struct PoolPair {
        address poolAddr;
        Pair pair;
    }

    struct DexPoolPair {
        address factory;
        PoolPair pool;
    }

    /**
     * @dev 获取池子信息
     * @param pool 池子地址
     * @return 池子信息和错误消息
     */
    function getPoolInfo(
        address pool
    ) public view returns (DexPoolPair memory, string memory) {
        DexPoolPair memory result;

        result.pool.poolAddr = pool;

        try IPair(pool).factory() returns (address _factory) {
            result.factory = _factory;
        } catch {
            return (result, "PoolQueryFactoryError");
        }

        try IPair(pool).token0() returns (address _token0) {
            result.pool.pair.token0 = _token0;
        } catch {
            return (result, "PoolQueryToken0Error");
        }

        try IPair(pool).token1() returns (address _token1) {
            result.pool.pair.token1 = _token1;
        } catch {
            return (result, "PoolQueryToken1Error");
        }

        try IERC20(result.pool.pair.token0).decimals() returns (
            uint8 _decimals0
        ) {
            result.pool.pair.decimal0 = _decimals0;
        } catch {
            return (result, "PoolQueryDecimals0Error");
        }

        try IERC20(result.pool.pair.token1).decimals() returns (
            uint8 _decimals1
        ) {
            result.pool.pair.decimal1 = _decimals1;
        } catch {
            return (result, "PoolQueryDecimals1Error");
        }

        return (result, "");
    }

    /**
     * @dev 批量获取池子信息
     * @param pools 池子地址数组
     * @return 池子信息数组和错误信息数组
     */
    function batchGetPoolInfo(
        address[] memory pools
    ) external view returns (DexPoolPair[] memory, string[] memory) {
        DexPoolPair[] memory results = new DexPoolPair[](pools.length);
        string[] memory errors = new string[](pools.length);

        for (uint256 i = 0; i < pools.length; i++) {
            (DexPoolPair memory result, string memory error) = getPoolInfo(
                pools[i]
            );
            results[i] = result;
            errors[i] = error;
        }
        return (results, errors);
    }
}

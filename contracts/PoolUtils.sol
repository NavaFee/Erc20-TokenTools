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

struct PoolKey {
    address currency0;
    address currency1;
    uint24 fee;
    int24 tickSpacing;
    address hooks;
}

contract PositionManager {
    mapping(bytes25 => PoolKey) public poolKeys;
}

contract PoolUtils {
    PositionManager public UniV4PositionManager;
    address public UniV4PoolManager;

    constructor(address _positionManager, address _poolManager) {
        UniV4PositionManager = PositionManager(_positionManager);
        UniV4PoolManager = _poolManager;
    }

    struct Pair {
        address token0;
        address token1;
        uint8 decimal0;
        uint8 decimal1;
    }

    struct PoolPair {
        bytes poolAddr;
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
        bytes memory pool
    ) public view returns (DexPoolPair memory, string memory) {
        DexPoolPair memory result;

        result.pool.poolAddr = pool;

        address _pool = address(bytes20(pool));

        try IPair(_pool).factory() returns (address _factory) {
            result.factory = _factory;
        } catch {
            return (result, "PoolQueryFactoryError");
        }

        try IPair(_pool).token0() returns (address _token0) {
            result.pool.pair.token0 = _token0;
        } catch {
            return (result, "PoolQueryToken0Error");
        }

        try IPair(_pool).token1() returns (address _token1) {
            result.pool.pair.token1 = _token1;
        } catch {
            return (result, "PoolQueryToken1Error");
        }

        // 处理 token0 的 decimals
        if (result.pool.pair.token0.code.length == 0) {
            result.pool.pair.decimal0 = 18;
        } else {
            try IERC20(result.pool.pair.token0).decimals() returns (
                uint8 _decimals0
            ) {
                result.pool.pair.decimal0 = _decimals0;
            } catch {
                return (result, "PoolQueryDecimals0Error");
            }
        }

        // 处理 token1 的 decimals
        if (result.pool.pair.token1.code.length == 0) {
            result.pool.pair.decimal1 = 18;
        } else {
            try IERC20(result.pool.pair.token1).decimals() returns (
                uint8 _decimals1
            ) {
                result.pool.pair.decimal1 = _decimals1;
            } catch {
                return (result, "PoolQueryDecimals1Error");
            }
        }

        return (result, "");
    }

    /**
     * @dev 批量获取池子信息
     * @param pools 池子地址数组
     * @return 池子信息数组和错误信息数组
     */
    function batchGetPoolInfo(
        bytes[] memory pools
    ) external view returns (DexPoolPair[] memory, string[] memory) {
        DexPoolPair[] memory results = new DexPoolPair[](pools.length);
        string[] memory errors = new string[](pools.length);

        for (uint256 i = 0; i < pools.length; i++) {
            // if pools[i] 为bytes20类型，则直接转换为address
            if (pools[i].length == 20) {
                (DexPoolPair memory result, string memory error) = getPoolInfo(
                    pools[i]
                );
                results[i] = result;
                errors[i] = error;
            } else {
                (
                    DexPoolPair memory result,
                    string memory error
                ) = getUniv4PoolInfo(pools[i]);
                results[i] = result;
                errors[i] = error;
            }
        }
        return (results, errors);
    }

    // 获取univ4池子信息
    /*
     * @dev 获取univ4池子信息
     * @param pool 池子地址
     * @return 池子信息和错误消息
     */
    function getUniv4PoolInfo(
        bytes memory pool
    ) public view returns (DexPoolPair memory, string memory) {
        DexPoolPair memory result;

        PoolKey memory poolKey;

        bytes25 poolId = bytes25(pool);

        try UniV4PositionManager.poolKeys(poolId) returns (
            address currency0,
            address currency1,
            uint24 fee,
            int24 tickSpacing,
            address hooks
        ) {
            poolKey = PoolKey(currency0, currency1, fee, tickSpacing, hooks);
        } catch {
            return (result, "PoolQueryPoolKeyError");
        }

        result.pool.poolAddr = pool;
        result.factory = UniV4PoolManager;

        result.pool.pair.token0 = poolKey.currency0;
        result.pool.pair.token1 = poolKey.currency1;

        // 处理 token0 的 decimals
        if (result.pool.pair.token0.code.length == 0) {
            result.pool.pair.decimal0 = 18;
        } else {
            try IERC20(result.pool.pair.token0).decimals() returns (
                uint8 _decimals0
            ) {
                result.pool.pair.decimal0 = _decimals0;
            } catch {
                return (result, "PoolQueryDecimals0Error");
            }
        }

        // 处理 token1 的 decimals
        if (result.pool.pair.token1.code.length == 0) {
            result.pool.pair.decimal1 = 18;
        } else {
            try IERC20(result.pool.pair.token1).decimals() returns (
                uint8 _decimals1
            ) {
                result.pool.pair.decimal1 = _decimals1;
            } catch {
                return (result, "PoolQueryDecimals1Error");
            }
        }

        return (result, "");
    }
}

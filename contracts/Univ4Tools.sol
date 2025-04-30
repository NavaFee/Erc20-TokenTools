// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

type Currency is address;

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

contract Univ4Tools {
    type PoolId is bytes32;

    event Bytes25(bytes25 poolId);
    event String(string poolId);
    event Bytes32(bytes32 poolId);
    event Bytes(bytes poolId);

    PositionManager public positionManager;

    constructor() {
        positionManager = PositionManager(
            0x4529A01c7A0410167c5740C487A8DE60232617bf
        );
    }

    function keyToId(PoolKey memory key) public pure returns (PoolId poolId) {
        poolId = PoolId.wrap(keccak256(abi.encode(key)));
    }

    function idToKey(
        string memory poolId
    ) public returns (PoolKey memory poolKey) {
        emit String(poolId);
        bytes memory poolIdBytes = hexStringToBytes(poolId);
        emit Bytes(poolIdBytes);
        bytes32 poolIdBytes32 = bytes32(poolIdBytes);
        emit Bytes32(poolIdBytes32);
        bytes25 _poolId = bytes25(poolIdBytes32);
        emit Bytes25(_poolId);
        (
            address currency0,
            address currency1,
            uint24 fee,
            int24 tickSpacing,
            address hooks
        ) = positionManager.poolKeys(_poolId);
        poolKey = PoolKey(currency0, currency1, fee, tickSpacing, hooks);
    }

    function hexStringToBytes(
        string memory s
    ) internal pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        if (ss.length >= 2 && ss[0] == "0" && (ss[1] == "x" || ss[1] == "X")) {
            bytes memory trimmed = new bytes(ss.length - 2);
            for (uint i = 2; i < ss.length; i++) {
                trimmed[i - 2] = ss[i];
            }
            ss = trimmed;
        }
        require(ss.length % 2 == 0, "Invalid hex string length");
        bytes memory r = new bytes(ss.length / 2);
        for (uint i = 0; i < ss.length / 2; ++i) {
            r[i] = bytes1(
                hexCharToByte(ss[2 * i]) * 16 + hexCharToByte(ss[2 * i + 1])
            );
        }
        return r;
    }

    function hexCharToByte(bytes1 c) internal pure returns (uint8) {
        if (uint8(c) >= 48 && uint8(c) <= 57) {
            return uint8(c) - 48;
        }
        if (uint8(c) >= 97 && uint8(c) <= 102) {
            return uint8(c) - 87;
        }
        if (uint8(c) >= 65 && uint8(c) <= 70) {
            return uint8(c) - 55;
        }
        revert("Invalid hex character");
    }
}

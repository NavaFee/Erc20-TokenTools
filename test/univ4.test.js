const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Univ4Tools", function () {
  async function deployFixture() {
    const [owner] = await ethers.getSigners();

    // 部署合约
    const Univ4Tools = await ethers.getContractFactory("Univ4Tools");
    const univ4Tools = await Univ4Tools.deploy();

    return {
      univ4Tools,
      owner,
    };
  }

  it("should get pool info", async function () {
    const { univ4Tools, owner } = await loadFixture(deployFixture);

    const poolId =
      "0x8aa4e11cbdf30eedc92100f4c8a31ff748e201d44712cc8c90d189edaa8e4e47";
    console.log("poolId", poolId);

    // {
    //   "currency0": "0x078d782b760474a361dda0af3839290b0ef57ad6",
    //   "currency1": "0x927b51f251480a681271180da4de28d44ec4afb8",
    //   "fee": "3000",
    //   "tickSpacing": "60",
    //   "hooks": "0x0000000000000000000000000000000000000000"
    // }

    const poolInfo = await univ4Tools.idToKey(poolId);
    console.log(poolInfo);
  });
});

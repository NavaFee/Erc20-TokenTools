const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PoolUtils", function () {
  // 增加超时时间到 2 分钟
  this.timeout(1200000);

  it("should get pool info", async function () {
    const [owner] = await ethers.getSigners();

    // 部署合约
    const PoolUtils = await ethers.getContractFactory("PoolUtils");

    const univ4PositionManager = "0xbD216513d74C8cf14cf4747E6AaA6420FF64ee9e";
    const univ4PoolManager = "0x000000000004444c5dc75cB358380D2e3dE08A90";

    const poolUtils = await PoolUtils.deploy(
      univ4PositionManager,
      univ4PoolManager
    );

    const poolAddresses = [
      "0x5E48d150742A15E5E53317d3aAF869fAbB8e09BF",
      "0x8aa4e11cbdf30eedc92100f4c8a31ff748e201d44712cc8c90d189edaa8e4e47",
    ];

    // 只调用一次 batchGetPoolInfo

    const poolInfo = await poolUtils.batchGetPoolInfo(poolAddresses);

    console.log("Pool Info:", poolInfo);
    console.log("First Pool Info:", poolInfo[0]);
  });
});

const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("TokenUtils", function () {
  async function deployFixture() {
    const [owner] = await ethers.getSigners();

    // 部署合约
    const TokenUtils = await ethers.getContractFactory("TokenUtils");
    const tokenUtils = await TokenUtils.deploy();

    // 部署erc20合约
    const ERC20 = await ethers.getContractFactory("ERC20");
    const erc20 = await ERC20.deploy();

    return {
      tokenUtils,
      erc20,
      owner,
    };
  }

  it("should get token info", async function () {
    const { tokenUtils, owner, erc20 } = await loadFixture(deployFixture);

    const erc20Address = await erc20.getAddress();
    console.log("erc20Address", erc20Address);

    const tokenAddresses = [
      process.env.BASE_WETH,
      process.env.BASE_VIRTUAL,
      process.env.BASE_USDC,
      process.env.BASE_STAR,
      process.env.BASE_LUNA,
      process.env.BASE_USDT,
      process.env.BASE_WAI,
      process.env.BASE_AIXBT,
      "0x827922686190790b37229fd06084350E74485b72",
      "0x0000000000000000000000000000000000000000",
      "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
      // "0x1c7d4b196cb0c7b01d743fbc6116a902379c7238",
      // "0xee567fe1712faf6149d80da1e6934e354124cfe3",
      // "0x72e46e15ef83c896de44b1874b4af7ddab5b4f74",
      // "0xA3dE85a6eAEE4B6bC1200420F6AF69Bd099DdE9C",
      erc20Address,
    ];

    const tokenInfo = await tokenUtils.getTokenInfo(tokenAddresses);
    console.log(tokenInfo);
  });
});

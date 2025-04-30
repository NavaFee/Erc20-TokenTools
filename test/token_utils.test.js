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
      "0x940181a94A35A4569E4529A3CDfB74e38FD98631",
      "0x4200000000000000000000000000000000000006",
    ];

    const tokenInfo = await tokenUtils.getTokenInfo(tokenAddresses);
    console.log(tokenInfo);
  });
});

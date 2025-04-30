const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("BalanceUtils合约测试", function () {
  async function deployFixture() {
    const [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // 部署BalanceUtils合约
    const BalanceUtils = await ethers.getContractFactory("BalanceUtils");
    const balanceUtils = await BalanceUtils.deploy();

    // 部署两个标准ERC20代币
    const MockToken = await ethers.getContractFactory("MockToken");
    const mockToken1 = await MockToken.deploy("Token One", "TKN1", 18);
    const mockToken2 = await MockToken.deploy("Token Two", "TKN2", 6);

    // 部署一个有问题的代币，会导致balanceOf失败
    const BadToken = await ethers.getContractFactory("BadToken");
    const badToken = await BadToken.deploy();

    // 获取合约地址
    const mockToken1Address = await mockToken1.getAddress();
    const mockToken2Address = await mockToken2.getAddress();
    const badTokenAddress = await badToken.getAddress();

    // 为测试账户发送一些代币
    await mockToken1.mint(addr1.address, ethers.parseEther("1000"));
    await mockToken2.mint(addr1.address, ethers.parseUnits("2000", 6));
    await mockToken1.mint(addr2.address, ethers.parseEther("500"));
    await mockToken2.mint(addr2.address, ethers.parseUnits("1500", 6));

    return {
      balanceUtils,
      mockToken1,
      mockToken2,
      badToken,
      mockToken1Address,
      mockToken2Address,
      badTokenAddress,
      owner,
      addr1,
      addr2,
      addrs,
    };
  }

  function serializeBigInt(obj) {
    return JSON.parse(
      JSON.stringify(obj, (key, value) =>
        typeof value === "bigint" ? value.toString() : value
      )
    );
  }

  it("应该正确返回多个地址的多个代币余额", async function () {
    const { balanceUtils, mockToken1Address, mockToken2Address, addr1, addr2 } =
      await loadFixture(deployFixture);

    const req = [
      {
        owner: addr1.address,
        tokenAddresses: [mockToken1Address, mockToken2Address],
      },
      {
        owner: addr2.address,
        tokenAddresses: [mockToken1Address, mockToken2Address],
      },
    ];

    const results = await balanceUtils.getBatchTokensBalance(req);

    // 使用自定义函数序列化结果
    console.log(JSON.stringify(serializeBigInt(results), null, 2));

    // 验证结果数量
    expect(results.length).to.equal(2);

    // 验证第一个用户的信息
    expect(results[0].user).to.equal(addr1.address);
    expect(results[0].tokenAddresses.length).to.equal(2);
    expect(results[0].balances.length).to.equal(2);
    expect(results[0].balances[0]).to.equal(ethers.parseEther("1000"));
    expect(results[0].balances[1]).to.equal(ethers.parseUnits("2000", 6));

    // 验证第二个用户的信息
    expect(results[1].user).to.equal(addr2.address);
    expect(results[1].tokenAddresses.length).to.equal(2);
    expect(results[1].balances.length).to.equal(2);
    expect(results[1].balances[0]).to.equal(ethers.parseEther("500"));
    expect(results[1].balances[1]).to.equal(ethers.parseUnits("1500", 6));
  });

  it("当查询有问题的代币时，应返回0余额而不是报错", async function () {
    const {
      balanceUtils,
      mockToken1Address,
      mockToken2Address,
      badTokenAddress,
      addr1,
    } = await loadFixture(deployFixture);

    const req = [
      {
        owner: addr1.address,
        tokenAddresses: [mockToken1Address, badTokenAddress, mockToken2Address],
      },
    ];

    const results = await balanceUtils.getBatchTokensBalance(req);

    // 使用自定义函数序列化结果
    console.log(JSON.stringify(serializeBigInt(results), null, 2));

    // 验证结果
    expect(results.length).to.equal(1);
    expect(results[0].balances.length).to.equal(3);

    // 正常代币应返回正确余额
    expect(results[0].balances[0]).to.equal(ethers.parseEther("1000"));
    // 有问题的代币应返回0
    expect(results[0].balances[1]).to.equal(0);
    // 正常代币应返回正确余额
    expect(results[0].balances[2]).to.equal(ethers.parseUnits("2000", 6));
  });

  it("应该返回正确的原生代币余额", async function () {
    const { balanceUtils, mockToken1Address, owner, addr1 } = await loadFixture(
      deployFixture
    );

    // 向测试地址发送一些ETH
    await owner.sendTransaction({
      to: addr1.address,
      value: ethers.parseEther("10"),
    });

    const req = [
      {
        owner: addr1.address,
        tokenAddresses: [mockToken1Address],
      },
    ];

    const results = await balanceUtils.getBatchTokensBalance(req);

    // 使用自定义函数序列化结果
    console.log(JSON.stringify(serializeBigInt(results), null, 2));

    // 验证原生代币余额
    expect(results[0].mainBalance).to.be.gte(ethers.parseEther("10"));
  });
});

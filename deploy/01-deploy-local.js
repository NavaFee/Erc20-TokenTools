const { network, ethers } = require("hardhat");
const { log, deploy } = deployments; // 确保导入log
require("dotenv").config();

module.exports = async function ({ getNamedAccounts, deployments }) {
  if (network.name !== "hardhat") {
    console.log("This script is only for local testing");
    return;
  }
  const { deployer } = await getNamedAccounts();

  log("----------------------------------------------------");

  const tokenUtils = await deploy("TokenUtils", {
    from: deployer,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  console.log("合约部署地址:", tokenUtils.address);

  log("------------------------------------");
};

module.exports.tags = ["all", "tokenUtils", "hardhat"];

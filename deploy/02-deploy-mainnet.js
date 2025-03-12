const { network, ethers } = require("hardhat");

require("dotenv").config();
const fs = require("fs");

module.exports = async function ({ getNamedAccounts, deployments }) {
  if (network.name !== "mainnet") {
    console.log("This script is only for mainnet");
    return;
  }
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("deployer:", deployer);

  log("----------------------------------------------------");

  // const tokenUtils = await deploy("TokenUtils", {
  //   from: deployer,
  //   log: true,
  //   waitConfirmations: network.config.blockConfirmations || 1,
  // });
  // console.log("合约部署地址:", tokenUtils.address);

  log("------------------------------------");
};

module.exports.tags = ["all", "tokenUtils", "mainnet"];

const { expect, assert } = require("chai");
const { ethers, network } = require("hardhat");

const amount = ethers.utils.parseEther("999999999999999");

describe("ERA", function () {
  let era, erc20Token, mintNFt;

  beforeEach(async () => {
    accounts = await ethers.getSigners();

    // deploy erc20 contract
    const USDCToken = await ethers.getContractFactory("USDCToken");
    erc20Token = await USDCToken.deploy(amount);
    await erc20Token.deployed();

    // deploy MintNFt.sl
    const MinftNFt = await ethers.getContractFactory("MinftNFt");
    mintNFt = await MinftNFt.deploy();
    await mintNFt.deployed();

    // deploy ERA.sol
    const ERA = await ethers.getContractFactory("ERA");
    era = await ERA.deploy();
    await era.deployed();

    // mint nft and approve
    await mintNFt.mintNFT("Hey");
    await mintNFt.approve(era.address, "1");
  });

  describe("list", function () {
    describe("Positive cases", function () {
      it("", async function () {});
    });

    describe("Negative cases", function () {
      it("", async function () {
        console.log("HI");
      });
    });
  });
});

import fs from "fs/promises";
import { ethers } from "hardhat";
import contracts from "./contracts.json";

const parseEth = (val: any) => ethers.utils.parseEther(val);

const main = async () => {
  try {
    const omniContractAddress = contracts.OmnichainERA;
    const nftContractAddress = contracts.MintNFt;
    const eraContractAddress = contracts.ERA;
    const uSDCTokenAddresss = contracts.USDCToken;

    console.log(omniContractAddress, nftContractAddress, eraContractAddress);

    // Connect to the contracts using ethers
    const [signer] = await ethers.getSigners();

    const nftContract = await ethers.getContractAt(
      "MinftNFt",
      nftContractAddress,
      signer
    );

    const uSDCToken = await ethers.getContractAt(
      "USDCToken",
      uSDCTokenAddresss,
      signer
    );

    console.log(`🔑 Using account: ${signer.address}\n`);

    for (let i = 0; i < 20; i++) {
      try {
        // mint nft and approve era_contract
        const tx = await nftContract.mintNFT("XYX");
        await tx.wait();

        await nftContract.approve(eraContractAddress, i + 1);

        console.log(`Minted NFT #${i + 1}`);

        // You can add more specific error handling here if needed
      } catch (mintError) {
        console.error(`Error minting NFT #${i + 1}:`, mintError);
      }
    }

    await uSDCToken.approve(eraContractAddress, parseEth("999999"));

    // The rest of your code...
  } catch (error) {
    console.error("Error reading or interacting with contracts:", error);
  }
};

main();

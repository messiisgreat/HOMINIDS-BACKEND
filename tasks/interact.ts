import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { parseEther } from "@ethersproject/units";
import { getAddress } from "@zetachain/protocol-contracts";
import { prepareData, trackCCTX } from "@zetachain/toolkit/helpers";
import contracts from "../scripts/contracts.json";

const ethers = require("ethers");
const parseEth = (val: any) => ethers.utils.parseEther(val);

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {
  const [signer] = await hre.ethers.getSigners();
  console.log(`🔑 Using account: ${signer.address}\n`);

  console.log("Contracts : ", contracts);
  let data;
  const select = args.select;

  const omniContractAddress = contracts.OmnichainERA;
  const nftContractAddress = contracts.MintNFt;
  const paymentToken = contracts.USDCToken;

  const amountToListBuy = parseEth("2");
  const delistId = "0";
  const dlist = "0";
  const tokenIdToList = "2"; // tokenId of nft to list
  const offerListId = "0";

  const listIdToBuy = "1"; // list id to buy
  const listIdToOffer = "0"; //lsit it offer

  if (select === "0") {
    // store data
    data = prepareData(omniContractAddress, ["uint8", "uint8"], [select, "90"]);
  } else if (select === "1") {
    // list
    data = prepareData(
      omniContractAddress,
      ["uint8", "address", "uint64", "address", "uint64"],
      [select, nftContractAddress, tokenIdToList, paymentToken, amountToListBuy]
    );

    console.log(
      "Select : ",
      select,
      " NFTContractAddr : ",
      nftContractAddress,
      " tokenId : ",
      tokenIdToList,
      " paymentToken : ",
      paymentToken,
      " amount to buy : ",
      amountToListBuy
    );
  } else if (select === "2") {
    // delist

    data = prepareData(
      omniContractAddress,
      ["uint8", "uint64"],
      [select, delistId]
    );
  } else if (select === "3") {
    // changePrice

    data = prepareData(
      omniContractAddress,
      ["uint8", "uint64", "address", "uint64"],
      [select, offerListId, paymentToken, amountToListBuy]
    );
  } else if (select === "4") {
    // buy

    data = prepareData(
      omniContractAddress,
      ["uint8", "uint64"],
      [select, listIdToBuy]
    );
  } else if (select === "5") {
    // make offer

    data = prepareData(
      omniContractAddress,
      ["uint8", "uint64", "address", "uint64"],
      [select, listIdToOffer, paymentToken, amountToListBuy]
    );
  } else if (select === "6") {
    // accept offer

    data = prepareData(
      omniContractAddress,
      ["uint8", "uint64", "uint64"],
      [select, listIdToOffer, offerListId]
    );
  } else if (select === "7") {
    // accept offer

    data = prepareData(
      omniContractAddress,
      ["uint8", "uint64", "uint64"],
      [select, listIdToOffer, offerListId]
    );
  } else if (select === "244") {
    // mint

    data = prepareData(omniContractAddress, ["uint8"], [select]);
  }
  // 5fe578480cd2C11B313c70AeD4360FdF6C9d0Df92b05bc6e548D690Af43f3ab3D041cac56A396D19A0b3F6Bf00000000000000012dC9E747A4A1B1F74eaF26b5AF0A8381600572d91BC16D674EC80000

  console.log("data to pass : ", data);

  const to = getAddress("tss", hre.network.name);
  const value = parseEther("0.0001");

  const tx = await signer.sendTransaction({ data, to, value });

  console.log(`
  🚀 Successfully broadcasted a token transfer transaction on ${hre.network.name} network.
  📝 Transaction hash: ${tx.hash}
  `);
  await trackCCTX(tx.hash);
};

task("interact", "Interact with the contract")
  // .addParam("contract", "The address of the withdraw contract on ZetaChain")
  // .addParam("amount", "Amount of tokens to send")
  .addParam("select", "select something")
  .setAction(main);

import { getAddress } from "@zetachain/protocol-contracts";
import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

// ERA :  0xFCE15f9e3d3f482f292298176E198218B54eC790

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {
  if (hre.network.name !== "zeta_testnet") {
    throw new Error(
      '🚨 Please use the "zeta_testnet" network to deploy to ZetaChain.'
    );
  }

  const [signer] = await hre.ethers.getSigners();
  if (signer === undefined) {
    throw new Error(
      `Wallet not found. Please, run "npx hardhat account --save" or set PRIVATE_KEY env variable (for example, in a .env file)`
    );
  }
  console.log(`🔑 Using account: ${signer.address}\n`);

  const systemContract = getAddress("systemContract", "zeta_testnet");

  const factory = await hre.ethers.getContractFactory("Minter");

  const contract = await factory.deploy(
    "Vishal",
    "VD",
    "Just for fun",
    80001,
    systemContract,
    "0x167e2eaF080Ed76afd28Ae7071764cCa2B9B7716"
  );
  await contract.deployed();

  console.log(`🚀 Successfully deployed contract on ZetaChain.
  📜 Contract address: ${contract.address}
  🌍 Explorer: https://athens3.explorer.zetachain.com/address/${contract.address}
  `);
};

task("deploy", "Deploy the contract", main);

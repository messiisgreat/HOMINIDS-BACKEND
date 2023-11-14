const { AsyncLocalStorage } = require("async_hooks");
const { expect, assert } = require("chai");
const { ethers, network } = require("hardhat");

const amount = ethers.utils.parseEther("999999999999999");
const ask1 = ethers.utils.parseEther("50");
const ask2 = ethers.utils.parseEther("89");

const parseEth = (val) => ethers.utils.parseEther(val);

describe("ERA", function () {
  let era,
    erc20Token,
    token2,
    mintNFt,
    lister1,
    lister2,
    buyer1,
    buyer2,
    offerer1;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    lister1 = accounts[1];
    lister2 = accounts[2];
    buyer1 = accounts[3];
    buyer2 = accounts[4];
    offerer1 = accounts[5];

    // deploy erc20 contract
    const USDCToken = await ethers.getContractFactory("USDCToken");
    erc20Token = await USDCToken.deploy(amount);
    await erc20Token.deployed();

    // another token
    const USDCToken1 = await ethers.getContractFactory("USDCToken");
    token2 = await USDCToken1.deploy(amount);
    await token2.deployed();

    // deploy MintNFt.sl
    const MinftNFt = await ethers.getContractFactory("MinftNFt");
    mintNFt = await MinftNFt.deploy();
    await mintNFt.deployed();

    // deploy ERA.sol
    const ERA = await ethers.getContractFactory("ERA");
    era = await ERA.deploy();
    await era.deployed();

    // mint nft and approve
    await mintNFt.connect(lister1).mintNFT("Hey");
    await mintNFt.connect(lister1).approve(era.address, "1");

    await mintNFt.connect(lister2).mintNFT("XYZ");
    await mintNFt.connect(lister2).approve(era.address, "2");

    // transfer fund to buyer1 and buyer2. approve to era contract
    await erc20Token.transfer(buyer1.address, parseEth("1000"));
    await erc20Token.transfer(buyer2.address, parseEth("1000"));
    await erc20Token.connect(buyer1).approve(era.address, parseEth("100"));
    await erc20Token.connect(buyer2).approve(era.address, parseEth("100"));

    // tranfer amount to offer1
    await token2.transfer(offerer1.address, parseEth("1000"));
    await token2.connect(offerer1).approve(era.address, parseEth("1000"));
  });

  describe.only("Integrated test", function () {
    it("run", async function () {
      /////////////// list nfts ///////////////
      await expect(
        era
          .connect(lister1)
          .list(lister1.address, mintNFt.address, "1", erc20Token.address, ask1)
      )
        .to.emit(era, "Listed")
        .withArgs(
          "0",
          lister1.address,
          mintNFt.address,
          "1",
          erc20Token.address,
          ask1,
          era.address
        );

      await expect(
        era
          .connect(lister2)
          .list(lister2.address, mintNFt.address, "2", erc20Token.address, ask2)
      )
        .to.emit(era, "Listed")
        .withArgs(
          "1",
          lister2.address,
          mintNFt.address,
          "2",
          erc20Token.address,
          ask2,
          era.address
        );

      /////////////// buy ///////////////
      const marketplace = await era.marketplace();
      const fee_pbs = marketplace.fee_pbs.toString();
      const collateral = marketplace.collateral_fee.toString();
      // const calFee1 = await era.calculate_fees(ask1, fee_pbs, collateral);
      // const royaltyFee = await era.calculateRoyaltyCollectionFee(
      //   mintNFt.address,
      //   ask1
      // );

      // const totalAmount = ask1.add(calFee1).add(royaltyFee);

      await expect(era.connect(buyer1).buy(buyer1.address, "0")).to.emit(
        era,
        "ItemPurchased"
      );

      const ownerOfNft1 = await mintNFt.ownerOf("1");
      assert.equal(ownerOfNft1, buyer1.address);

      // offerer1 offeres 999 token2 for nft2
      await expect(
        era
          .connect(offerer1)
          .makeOffer("1", offerer1.address, token2.address, parseEth("999"))
      ).to.emit(era, "Offered");

      let nft2OffersArray = await era.listIdToOffers("1", "0");
      console.log(nft2OffersArray);

      // lister2 accepts offer of offerer1
      await era.connect(lister2).acceptOffer("1", "0");
      nft2OffersArray = await era.listIdToOffers("1", "0");
      console.log(nft2OffersArray);
      assert(nft2OffersArray.accepted);
    });
  });
});

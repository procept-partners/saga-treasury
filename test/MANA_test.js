const { expect } = require("chai");
const { ethers } = require("hardhat");
const { ZeroAddress } = ethers;

describe("ManaToken Contract Tests", function () {
  let MANA;
  let ManaToken;
  let mana;
  let manaToken;
  let owner;
  let user1;
  let user2;
  let defaultOperators;
  let defaultPartitions;

  beforeEach(async function () {
    [owner, user1, user2, ...defaultOperators] = await ethers.getSigners();
    
    defaultPartitions = [
      ethers.keccak256(ethers.toUtf8Bytes("collateralized")),
      ethers.keccak256(ethers.toUtf8Bytes("uncollateralized"))
    ];

    MANA = await ethers.getContractFactory("MANA");
    mana = await MANA.deploy(
      defaultOperators.map(op => op.address),
      defaultPartitions
    );

    await mana.waitForDeployment();
    const manaAddress = await mana.getAddress();

    ManaToken = await ethers.getContractFactory("ManaToken");
    manaToken = await ManaToken.deploy(
      ethers.parseEther("1000000"), 
      manaAddress
    );
    await manaToken.waitForDeployment();

    await mana.transferOwnership(await manaToken.getAddress());
  });

  describe("Basic Token Functionality", function () {
    it("Should have correct initial supply assigned to owner", async function () {
      const initialSupply = ethers.parseEther("1000000");
      const ownerBalance = await manaToken.balanceOf(owner.address);
      expect(ownerBalance).to.equal(initialSupply);
    });

    it("Should have correct name and symbol", async function () {
      expect(await manaToken.name()).to.equal("Uncollateralized Mana");
      expect(await manaToken.symbol()).to.equal("mana");
    });

    it("Should allow transfers between accounts", async function () {
      const transferAmount = ethers.parseEther("100");
      await manaToken.transfer(user1.address, transferAmount);
      expect(await manaToken.balanceOf(user1.address)).to.equal(transferAmount);
    });
  });

  describe("Cooperative Contribution", function () {
    const contributionAmount = ethers.parseEther("100");

    beforeEach(async function () {
      // Transfer some tokens to user1 for testing
      await manaToken.transfer(user1.address, contributionAmount);
    });

    it("Should allow users to contribute to cooperative", async function () {
      await manaToken.connect(user1).contributeToCooperative(contributionAmount);
      
      // Check ERC20 token was burned
      expect(await manaToken.balanceOf(user1.address)).to.equal(0);
      
      // Check uncollateralized MANA was minted
      const uncollateralizedPartition = ethers.keccak256(ethers.toUtf8Bytes("uncollateralized"));
      const manaBalance = await mana.balanceOfByPartition(user1.address, uncollateralizedPartition);
      expect(manaBalance).to.equal(contributionAmount);
    });

    it("Should fail if user tries to contribute more than their balance", async function () {
      const tooMuch = contributionAmount * 2n;
      await expect(
        manaToken.connect(user1).contributeToCooperative(tooMuch)
      ).to.be.reverted;
    });
  });

  describe("Collateralized MANA Purchase", function () {
    const purchaseAmount = ethers.parseEther("100");

    it("Should allow owner to purchase collateralized MANA", async function () {
      await manaToken.purchaseCollateralizedMana(purchaseAmount);
      
      const collateralizedPartition = ethers.keccak256(ethers.toUtf8Bytes("collateralized"));
      const manaBalance = await mana.balanceOfByPartition(owner.address, collateralizedPartition);
      expect(manaBalance).to.equal(purchaseAmount);
    });

    it("Should not allow non-owner to purchase collateralized MANA", async function () {
      await expect(
        manaToken.connect(user1).purchaseCollateralizedMana(purchaseAmount)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
    it("Should verify MANA contract ownership", async function () {
        const manaOwner = await mana.owner();
        const manaTokenAddress = await manaToken.getAddress();
        expect(manaOwner).to.equal(manaTokenAddress);
      });
  });

  describe("Integration with MANA Contract", function () {
    it("Should have correct MANA contract reference", async function () {
      const manaContractAddress = await manaToken.manaGovernanceToken();
      expect(manaContractAddress).to.equal(await mana.getAddress());
    });

    it("Should correctly interact with MANA contract during contribution", async function () {
      const amount = ethers.parseEther("100");
      await manaToken.transfer(user1.address, amount);
      
      await manaToken.connect(user1).contributeToCooperative(amount);
      
      const uncollateralizedPartition = ethers.keccak256(ethers.toUtf8Bytes("uncollateralized"));
      const manaBalance = await mana.balanceOfByPartition(user1.address, uncollateralizedPartition);
      expect(manaBalance).to.equal(amount);
    });
  });
});
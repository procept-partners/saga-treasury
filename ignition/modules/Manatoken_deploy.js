async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());
    const initalSupply = 100000;
    const manaToken = await ethers.getContractFactory("ManaToken");
    const contract = await manaToken.deploy(initalSupply,"0x933d0A9A4d6CdA0fDfa5FE1dDA24eC18Eca3fCCC"); // Initially 100000 tokens
    await contract.waitForDeployment();
    console.log("Contract deployed to:", await contract.getAddress());
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
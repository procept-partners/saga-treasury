async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());
  // (trusted accounts)
  const defaultOperators = ["0xbcDc0883787BA970d450917724CeB73059720265", "0x21310a7f2c88194fb70194df679b260F024cCF77"]; 
  const defaultPartitions = [
    ethers.keccak256(ethers.toUtf8Bytes("collateralized")),
    ethers.keccak256(ethers.toUtf8Bytes("uncollateralized"))
  ];
  const MANA_token = await ethers.getContractFactory("MANA");
  const MANA_contract = await MANA_token.deploy(defaultOperators,defaultPartitions);
  await MANA_contract.waitForDeployment();
  console.log("MANA Governance Token deployed to:", await MANA_contract.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

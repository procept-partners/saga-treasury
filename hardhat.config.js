require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.21",
      },
      {
        version: "0.8.0",
      },
      {
        version: "0.7.0",
      },
      {
        version: "0.6.0",
      },
      {
        version: "0.5.0",
      },
    ],
    settings: { optimizer: { enabled: true, runs: 200 } }
  },
  networks: {
    hardhat: {},

    // sepolia: {
    //   url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
    //   accounts: [process.env.PRIVATE_KEY]
    // },
    auroraTestnet: {
      url: `https://testnet.aurora.dev`,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  // etherscan: {
  //   apiKey: process.env.ETHERSCAN_API_KEY
  // }
};

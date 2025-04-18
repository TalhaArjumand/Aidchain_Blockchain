require("@nomiclabs/hardhat-truffle5");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();


console.log("RPC_URL:", process.env.RPC_URL);
console.log("PRIVATE_KEY:", process.env.PRIVATE_KEY);

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },

  networks: {
    besu: {
      url: "http://127.0.0.1:8545", // Replace if Besu is running on a different host
      accounts: [process.env.PRIVATE_KEY.startsWith("0x") ? process.env.PRIVATE_KEY : `0x${process.env.PRIVATE_KEY}`], 
      gas: "auto",
      gasPrice: "auto", // QBFT doesn't require gas fees
      chainId: 1337, // Ensure this matches your Besu network's chain ID
    },
    ganache: {
      url: process.env.RPC_URL,
      accounts: [process.env.PRIVATE_KEY.startsWith("0x") ? process.env.PRIVATE_KEY : `0x${process.env.PRIVATE_KEY}`],
    },
  },

  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },

  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },

  mocha: {
    timeout: 20000,
  },
};

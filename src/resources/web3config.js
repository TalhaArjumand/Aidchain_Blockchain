const { Config } = require("../utils");
const fs = require("fs");
const path = require("path");
const { ethers } = require("ethers");

// ✅ Use absolute path for reading artifact files
const getArtifact = (filename) =>
  JSON.parse(
    fs.readFileSync(
      path.resolve(__dirname, "../../contracts/artifacts", filename),
      { encoding: "utf8" }
    )
  )['abi'];

const provider = new ethers.providers.JsonRpcProvider(Config.RPC_URL || "http://127.0.0.1:8545");

  console.log("Contract Address:", Config.CONTRACTADDR);
console.log("Full Config:", Config);
console.log("Escrow Factory Address:", Config.ESCROWFACTORYCONTRACT);

// ──────────────────────────────────────
// ✅ Config
// ──────────────────────────────────────
const account = Config.ADMIN;
const account_pass = Config.ADMIN_PASS;

const tokenAddress = Config.CONTRACTADDR;
const operationsAddress = Config.OPERATIONSADDR;

// ──────────────────────────────────────
// ✅ Contracts
// ──────────────────────────────────────

const tokenContract = (_wallet) => {
  const walletInit = new ethers.Wallet(_wallet, provider);
  return new ethers.Contract(Config.CONTRACTADDR, getArtifact("Chats.json"), walletInit);
};

const getTokenContract = new ethers.Contract(
  Config.CONTRACTADDR,
  getArtifact("Chats.json"),
  provider
);

const operationsContract = (_wallet) => {
  const walletInit = new ethers.Wallet(_wallet, provider);
  return new ethers.Contract(Config.OPERATIONSADDR, getArtifact("Operations.json"), walletInit);
};

const getOpsContract = new ethers.Contract(
  Config.OPERATIONSADDR,
  getArtifact("Operations.json"),
  provider
);

const factoryContract = (_wallet, collectionAddress) => {
  const walletInit = new ethers.Wallet(_wallet, provider);
  return new ethers.Contract(collectionAddress, getArtifact("factory.json"), walletInit);
};

const escrowContract = (_wallet, contractAddress) => {
  const walletInit = new ethers.Wallet(_wallet, provider);
  return new ethers.Contract(contractAddress, getArtifact("escrow.json"), walletInit);
};

const getEscrowContract = (escrowContractAddress) => {
  return new ethers.Contract(escrowContractAddress, getArtifact("escrow.json"), provider);
};

const escrowFactoryContract = (_wallet) => {
  const walletInit = new ethers.Wallet(_wallet, provider);
  return new ethers.Contract(Config.ESCROWFACTORYCONTRACT, getArtifact("factory.json"), walletInit);
};

const getEscrowFactoryContract = new ethers.Contract(
  Config.ESCROWFACTORYCONTRACT,
  getArtifact("factory.json"),
  provider
);

// ──────────────────────────────────────
// ✅ Exports
// ──────────────────────────────────────
module.exports = {
  provider,
  tokenAddress,
  operationsAddress,
  tokenContract,
  operationsContract,
  getTokenContract,
  getOpsContract,
  account,
  account_pass,
  factoryContract,
  escrowContract,
  escrowFactoryContract,
  getEscrowContract,
  getEscrowFactoryContract,
};
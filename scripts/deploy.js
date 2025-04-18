const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("🚀 Deploying contracts with the account:", deployer.address);

  // Check deployer's ETH balance
  const balance = await deployer.getBalance();
  console.log("💰 Account balance (ETH):", ethers.utils.formatEther(balance));

  if (balance.eq(0)) {
    throw new Error("❌ Insufficient local ETH! Check your Besu account or private key.");
  }

  // ---------------------------------------------------------------------------
  // 1) Deploy Operations as an Upgradeable Proxy
  // ---------------------------------------------------------------------------
  console.log("🚀 Deploying Operations (upgradeable)...");
  const OperationsFactory = await ethers.getContractFactory("Operations");
  const operationsProxy = await upgrades.deployProxy(
    OperationsFactory,
    [],                 
    { initializer: "initialize" }
  );
  await operationsProxy.deployed();
  await operationsProxy.deployTransaction.wait();  // 🛠 Ensure transaction is mined
  console.log("✅ Operations Proxy deployed to:", operationsProxy.address);

  // ---------------------------------------------------------------------------
  // 2) Deploy Chats as an Upgradeable Proxy
  // ---------------------------------------------------------------------------
  console.log("🚀 Deploying Chats (upgradeable)...");
  const ChatsFactory = await ethers.getContractFactory("Chats");
  const chatsProxy = await upgrades.deployProxy(
    ChatsFactory,
    [operationsProxy.address],  
    { initializer: "initialize" }
  );
  await chatsProxy.deployed();
  await chatsProxy.deployTransaction.wait();  // 🛠 Ensure transaction is mined
  console.log("✅ Upgradeable CHATS Proxy deployed to:", chatsProxy.address);

  // ---------------------------------------------------------------------------
  // 3) 🚀 **Deploy chatsEscrowFactory.sol**
  // ---------------------------------------------------------------------------
  console.log("🚀 Deploying chatsEscrowFactory...");
  const EscrowFactory = await ethers.getContractFactory("chatsEscrowFactory");
  const escrowFactory = await EscrowFactory.deploy();
  await escrowFactory.deployed();
  await escrowFactory.deployTransaction.wait();  // 🛠 Ensure transaction is mined
  console.log("✅ chatsEscrowFactory deployed to:", escrowFactory.address);
}

// Run the deployment function
main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});

require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
  // ✅ Replace with the beneficiary wallet address
  const beneficiaryAddress = "0xC13A147480B7Dc73764C23Ba74C0F64a5fDc77a1";

  // ✅ How much ETH to send
  const amountInEther = "0.05"; // Sends 0.05 ETH

  // ✅ Create signer from admin private key
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL || "http://127.0.0.1:8545");
  const adminWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  console.log(`🔑 Funding from: ${adminWallet.address}`);
  console.log(`📤 Sending ${amountInEther} ETH to ${beneficiaryAddress}...`);

  // ✅ Send ETH
  const tx = await adminWallet.sendTransaction({
    to: beneficiaryAddress,
    value: ethers.utils.parseEther(amountInEther)
  });
  await tx.wait();

  console.log(`✅ Transaction Hash: ${tx.hash}`);
  console.log("⏳ Waiting for transaction to finalize...");

  // ✅ Check balance after funding
  const balance = await provider.getBalance(beneficiaryAddress);
  console.log(`💰 Updated Balance of ${beneficiaryAddress}: ${ethers.utils.formatEther(balance)} ETH`);
}

main().catch((error) => {
  console.error("❌ Error running script:", error);
  process.exit(1);
});
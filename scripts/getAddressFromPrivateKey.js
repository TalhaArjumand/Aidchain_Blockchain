// scripts/getAddressFromPrivateKey.js
const { ethers } = require("ethers");

const main = () => {
  const [,, privateKey] = process.argv;

  if (!privateKey) {
    console.error("❌ Please provide a private key.");
    process.exit(1);
  }

  try {
    const wallet = new ethers.Wallet(privateKey);
    console.log(`✅ Wallet address: ${wallet.address}`);
  } catch (err) {
    console.error("❌ Invalid private key:", err.message);
  }
};

main();
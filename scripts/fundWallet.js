// chats-blockchain/scripts/fundWallet.js
const { ethers } = require("ethers");
require("dotenv").config();

const main = async () => {
  const [,, recipient, amount = "0.05"] = process.argv;

  if (!recipient) {
    console.error("❌ Please provide a recipient wallet address.");
    process.exit(1);
  }

  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.ADMIN_PASS, provider);

  const tx = await wallet.sendTransaction({
    to: recipient,
    value: ethers.utils.parseEther(amount)
  });

  console.log(`🚀 Sent ${amount} ETH to ${recipient}`);
  console.log(`🔗 Tx Hash: ${tx.hash}`);

  await tx.wait();
  console.log("✅ Transaction mined.");
};

main().catch(err => {
  console.error("❌ Error:", err);
});
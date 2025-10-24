


# 🧱 AidChain Blockchain – Hyperledger Besu + QBFT  

A decentralized **blockchain-based infrastructure** built with **Hyperledger Besu (QBFT consensus)** to enable transparent, secure, and verifiable humanitarian aid distribution.

---

## 🚀 Project Overview  

AidChain forms the blockchain backbone of the **Convexity Humanitarian Aid Transfer System (CHATS)**.  
It ensures that every on-chain aid transaction — from minting and approval to disbursement — is fully traceable, auditable, and immutable.  

### 🎯 Key Objectives  
- ✅ Guarantee **transparency** in humanitarian fund distribution  
- 🔒 Provide **immutability** and **traceability** of all transactions  
- ⚙️ Enable **NGOs**, **Vendors**, and **Beneficiaries** to operate on a single decentralized network  
- 💬 Integrate seamlessly with backend services through **RabbitMQ** and **Node.js**

---

## 🧠 Architecture Overview  

┌────────────────────────────┐
│        Admin Panel         │
│      (Nuxt 3 Frontend)     │
└────────────┬───────────────┘
│ REST API
┌────────────▼───────────────┐
│       AidChain API         │
│ (Node.js, Express, RabbitMQ│
│   Sequelize, PostgreSQL)   │
└────────────┬───────────────┘
│ Queue
┌────────────▼───────────────┐
│     AidChain Blockchain    │
│ (Hyperledger Besu + QBFT)  │
│ Smart Contracts + Hardhat  │
└────────────────────────────┘

---

## ⚙️ Tech Stack  

| Layer | Technology |
|-------|-------------|
| **Blockchain** | Hyperledger Besu (QBFT consensus) |
| **Smart Contracts** | Solidity + Hardhat |
| **Automation** | Docker + Docker Compose |
| **Backend Interaction** | Node.js, ethers.js |
| **Queue System** | RabbitMQ |
| **Database Layer** | PostgreSQL (via backend) |
| **Infrastructure** | Multi-node QBFT network |

---

## 📦 Prerequisites  

Ensure the following are installed before running the project:

```bash
Docker
Docker Compose
Node.js (>= v14)
npm
Git


⸻

📁 Folder Structure

AidChain_Blockchain/
├── README.md
├── besu/
│   └── QBFT-Network/
│       ├── Node-1/
│       ├── Node-2/
│       ├── Node-3/
│       ├── Node-4/
│       ├── config/
│       │   ├── genesis.json
│       │   └── qbftConfigFile.json
│       ├── networkFiles/
│       │   ├── key
│       │   ├── key.pub
│       │   └── static-nodes.json
│       ├── docker-compose.yml
│       └── start-network.sh
├── scripts/
│   └── deploy.js
└── .env


⸻

🧪 Getting Started

1️⃣ Clone Repository

git clone https://github.com/TalhaArjumand/Aidchain_Blockchain.git
cd Aidchain_Blockchain

2️⃣ Checkout Branch

git checkout chats-blockchain

3️⃣ Start QBFT Network

cd besu/QBFT-Network
docker-compose up -d

4️⃣ Verify Node Status

docker ps

To view logs:

docker logs -f besu-node1

Expected output:

Imported #102321 / 0 tx / 0 pending


⸻

⚙️ Configuration

🔧 .env File

Used during smart contract deployment or API interaction:

PRIVATE_KEY=0x<your-private-key>
RPC_URL=http://127.0.0.1:8545

🪙 genesis.json

Defines:
	•	chainId
	•	QBFT parameters
	•	Initial validator list
	•	Account allocations

⚙️ qbftConfigFile.json

Specifies:
	•	Block time
	•	Epoch length
	•	Timeout settings

⸻

📄 Smart Contract Deployment

We use Hardhat for deploying and interacting with contracts.

# Start Besu network
docker-compose up -d

# In a separate terminal
cd chats-blockchain

# Deploy smart contracts
npx hardhat run scripts/deploy.js --network besu

Example Hardhat Config:

networks: {
  besu: {
    url: "http://127.0.0.1:8545",
    accounts: ["0x<private-key>"]
  }
}


⸻

🔁 Developer Workflow

Git Branching Convention

main                  → base branch (production-ready)
chats-blockchain      → active development branch
feature/<name>        → feature work
hotfix/<issue>        → bug fixes

Workflow Commands:

git checkout -b feature/new-feature
git add .
git commit -m "Add new feature"
git push origin feature/new-feature


⸻

🐳 Docker Commands

# Start network
docker-compose up -d

# Stop network
docker-compose down

# View logs
docker logs -f besu-node1


⸻

Contributors Guide
	•	Ensure .env is properly configured before running any script
	•	Avoid committing private keys or sensitive files
	•	Use descriptive commit messages
	•	Run and test locally before pushing any PRs
	•	Follow the naming conventions for branches and commits

⸻

📫 Contact

Maintainer: Talha Arjumand
For collaboration or queries, feel free to reach out via LinkedIn or email.

⸻

❤️ Credits

Developed with passion by the AidChain Team
Supervised under the FAST-NUCES Blockchain Systems Lab

“Transparency is the foundation of trust.”
— AidChain Blockchain Initiative
=======



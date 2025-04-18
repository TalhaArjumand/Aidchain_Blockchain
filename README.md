AidChain Blockchain - Hyperledger Besu + QBFT

Welcome to AidChain, a decentralized blockchain-based infrastructure built using Hyperledger Besu with QBFT (Istanbul Byzantine Fault Tolerance) consensus. This network forms the backbone of our transparent and verifiable financial aid distribution system.

⸻

🚀 Project Purpose

The AidChain blockchain is designed to:
	•	Ensure transparency in the distribution of humanitarian aid
	•	Enable NGOs and organizations to track aid transactions with immutable records
	•	Provide a scalable, secure, and fault-tolerant blockchain infrastructure

⸻

🧱 Tech Stack

Component	Description
Hyperledger Besu	Enterprise-grade Ethereum client for permissioned networks
QBFT	Byzantine Fault Tolerant consensus algorithm
Docker + Compose	Containerization and orchestration of Besu nodes
Node.js	Used for smart contract interaction tools
Hardhat	(Optional) For deploying and testing smart contracts



⸻

⚙️ Prerequisites

Make sure you have the following installed:
	•	Docker
	•	Docker Compose
	•	Node.js (>= v14 recommended)
	•	npm (Node Package Manager)
	•	Git

⸻

📂 Folder Structure Overview

AidChain-Blockchain/
├── README.md
├── besu/
│   └── QBFT-Network/
│       ├── Node-1/
│       │   └── data/
│       ├── Node-2/
│       └── Node-3/
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
└── scripts/
    └── deploy.js (Hardhat script)



⸻

🧪 Clone & Run Instructions

# 1. Clone the repository
$ git clone https://github.com/your-username/aidchain-blockchain.git
$ cd aidchain-blockchain

# 2. Check out the blockchain branch
$ git checkout blockchain

# 3. Start the QBFT Network
$ cd besu/QBFT-Network
$ docker-compose up -d

# 4. Verify if nodes are running
$ docker ps



⸻

📄 Configuration Files

.env

Make sure your .env file (used in smart contract deployment or API interaction) contains:

PRIVATE_KEY=0x<your-dev-wallet-private-key>
RPC_URL=http://127.0.0.1:8545

genesis.json

Defines:
	•	chainId
	•	QBFT parameters
	•	Account allocations
	•	Initial validators

qbftConfigFile.json

Custom configuration for:
	•	Block time
	•	Epoch length
	•	Timeout for proposals

networkFiles/

Contains:
	•	Node identity keys (key, key.pub)
	•	static-nodes.json: list of bootnodes and enode URLs

⸻

✅ Verify Node Status

Check if nodes are producing blocks:

# Tail logs for Node-1
$ docker logs -f besu-node1

You should see entries like:

Imported #102321 / 0 tx / 0 pending



⸻

📦 Smart Contract Deployment (Hardhat)

We use Hardhat to deploy contracts to our private Besu network:

# Start Besu first
$ docker-compose up -d

# In a separate terminal
$ cd chats-blockchain

# Deploy contracts
$ npx hardhat run scripts/deploy.js --network besu

Ensure that hardhat.config.js is configured for the local network with:

networks: {
  besu: {
    url: "http://127.0.0.1:8545",
    accounts: ["0x<private-key>"]
  }
}



⸻

🧑‍💻 Developer Best Practices

🔁 Git Workflow
	•	Use feature branches: feature/<feature-name>
	•	Push to your branch: git push origin feature/<feature-name>
	•	Create PRs to blockchain branch

🐳 Docker Commands

# Start network
$ docker-compose up -d

# Stop network
$ docker-compose down

# View logs
$ docker logs -f besu-node1



⸻

🙌 Contributors Guide
	•	Please ensure proper .env configuration before running any scripts.
	•	Avoid pushing private keys or sensitive data to GitHub.
	•	Open issues for any bugs or improvement ideas.

⸻

📬 Contact

For questions, contributions, or troubleshooting, feel free to reach out to the maintainers of this repo.

⸻

Made with ❤️ by the AidChain Team

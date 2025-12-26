

# AidChain Blockchain Infrastructure (Hyperledger Besu + QBFT)

AidChain is a private blockchain infrastructure built on Hyperledger Besu using QBFT consensus.  
It is designed to support transparent, auditable transaction execution for a humanitarian aid distribution platform.

---

## What This Repository Contains

This repository focuses on the blockchain layer:

- A multi-node QBFT Besu network (Docker Compose)
- Solidity smart contracts (Hardhat-based workflow)
- Deployment scripts and local RPC configuration

---

## System Architecture (High Level)

```text
Backend Services (Node.js / REST)
        │
        ▼
Message Queue (RabbitMQ)
        │
        ▼
AidChain Blockchain Network (Hyperledger Besu + QBFT)
        │
        ▼
Smart Contracts (Solidity / Hardhat)


⸻

Repository Structure

.
├── besu/
│   └── QBFT-Network/
│       ├── docker-compose.yml
│       ├── start-network.sh
│       ├── config/
│       │   ├── genesis.json
│       │   └── qbftConfigFile.json
│       ├── networkFiles/
│       │   ├── static-nodes.json
│       │   ├── key
│       │   └── key.pub
│       ├── Node-1/
│       ├── Node-2/
│       ├── Node-3/
│       └── Node-4/
├── scripts/
│   └── deploy.js
├── .env
└── README.md

Note: Folder names (Node-1, Node-2, etc.) may vary slightly depending on the network generator used.

⸻

Prerequisites
	•	Docker
	•	Docker Compose
	•	Node.js (v14+ recommended)
	•	npm
	•	Git

⸻

Quick Start

1) Clone the repository

git clone https://github.com/TalhaArjumand/Aidchain_Blockchain.git
cd Aidchain_Blockchain

2) Start the QBFT network

cd besu/QBFT-Network
docker-compose up -d

3) Verify the nodes are running

docker ps
docker logs -f besu-node1

You should see blocks importing (e.g., Imported #...).

⸻

RPC / Environment Configuration

Create or update .env at repo root:

RPC_URL=http://127.0.0.1:8545
PRIVATE_KEY=0x<your-private-key>

	•	RPC_URL should point to the exposed RPC endpoint from the QBFT network.
	•	PRIVATE_KEY is used by the deployment script / Hardhat wallet.

⸻

Smart Contract Deployment

From the repository root:

npm install
npx hardhat run scripts/deploy.js --network besu

If your Hardhat network name is different, update the command accordingly.

Example Hardhat network config pattern:

networks: {
  besu: {
    url: "http://127.0.0.1:8545",
    accounts: ["0x<private-key>"]
  }
}


⸻

Useful Docker Commands

# Start network
docker-compose up -d

# Stop network
docker-compose down

# View logs
docker logs -f besu-node1


⸻

Notes on QBFT Configuration
	•	genesis.json defines chain ID, validator set, and initial allocations.
	•	qbftConfigFile.json defines block time, epoch length, and timeouts.
	•	static-nodes.json controls static peer connections between nodes.

⸻

Maintainer

Talha Arjumand
Backend & Blockchain Developer
GitHub: https://github.com/TalhaArjumand

---

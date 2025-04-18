const fs = require("fs").promises;
const solc = require("solc");

async function compileContract(contractFileName) {
  try {
    console.log(`🚀 Compiling ${contractFileName}...`);

    // Load contract source code
    const sourceCode = await fs.readFile(`contracts/${contractFileName}`, "utf8");

    // Create Solidity Compiler Standard Input JSON
    const input = {
      language: "Solidity",
      sources: { [contractFileName]: { content: sourceCode } },
      settings: { outputSelection: { "*": { "*": ["abi", "evm.bytecode"] } } },
    };

    // Compile the contract
    const output = JSON.parse(solc.compile(JSON.stringify(input)));

    // Extract the contract name dynamically
    const contractName = Object.keys(output.contracts[contractFileName])[0];

    // Retrieve ABI & Bytecode
    const artifact = {
      abi: output.contracts[contractFileName][contractName].abi,
      bytecode: output.contracts[contractFileName][contractName].evm.bytecode.object,
    };

    // Save ABI & Bytecode to artifacts folder
    await fs.writeFile(`artifacts/contracts/${contractName}.json`, JSON.stringify(artifact, null, 2));

    console.log(`✅ Compilation successful! ABI & Bytecode saved in artifacts/contracts/${contractName}.json\n`);
  } catch (error) {
    console.error(`❌ Compilation failed for ${contractFileName}:`, error);
  }
}

// List of contracts to compile
async function main() {
  await compileContract("Operations.sol");
  await compileContract("Chats.sol");
  await compileContract("chatsEscrowFactory.sol");
}

// Run compilation
main().then(() => process.exit(0));

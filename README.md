## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

A Summary:

# Foundry: A Framework for Smart Contract Development

## Introduction
Foundry is a **powerful and modular framework** for smart contract development using Solidity. It provides a comprehensive toolchain that streamlines dependency management, project compilation, testing, deployment, and interaction with the blockchain. Unlike other frameworks that rely on JavaScript or TypeScript, Foundry enables developers to write and execute Solidity scripts directly, making it a unique and user-friendly choice.

## Features
### Forge
A tool for developing, testing, and deploying smart contracts.

### Cast
A command-line tool for interacting with smart contracts, sending transactions, and retrieving blockchain data.

### Anvil
A local Ethereum Virtual Machine (EVM) node for testing and simulation.

### Chisel
An integrated Solidity REPL (Read-Eval-Print Loop) for interactive development.

## Scripting Capabilities
Foundry supports:
- Local and on-chain simulations.
- Transaction broadcasting.
- Contract verification.

This versatility and efficiency make Foundry an excellent tool for Solidity developers.

## Framework Comparison
- **Foundry**: Best for developers who value speed, simplicity, and a Solidity-first approach.
- **Hardhat**: Ideal for those who need a full-featured, customizable environment with a large community and extensive resources.
- **Truffle**: Suitable for projects requiring comprehensive development tools and security, especially for multi-chain projects.


# Deploying a Smart Contract Using Foundry

## Prerequisites
Ensure Foundry is installed. You can install Foundry by running:
```bash
curl -L https://foundry.paradigm.xyz | bash
``` 
follow what is written. then 
```bash
foundryup
```

Deployment Steps
1. Initialize the Project
Use forge init to initialize the project. If the directory is not empty, add the --force flag:
```bash
forge init --force
```
2. Create a Smart Contract File
Create a new file under the src directory (e.g., SC.sol).
3. Compile the Contract
Run the following to build or compile your contract:
```bash
forge build
or
forge compile
```
4. Deploy the Contract Locally
Use forge create to deploy your smart contract:
```bash
forge create XXXSmartContractNameXXX
```
5. Deploy On-Chain
Run Anvil, retrieve the private key and URL info.
Open a new terminal and deploy using the following command:
```bash
forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --interactive
```
6. Deploy Using a Script
Use the following to deploy your contract with a script:
```bash
forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```
Additional Tips
To convert a hexadecimal gas value to decimal, use:
```bash
cast --to-base 0xb296a dec
```

# Secure Deployment: Using Environment Variables for Private Key

## Avoid Writing Your Private Key Directly on the Command Line

### Step 1: Create a `.env` File
Create a new `.env` file in your project directory and add the following lines:
```
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://127.0.0.1:8545
```
### Step 2: Add .env to .gitignore
Make sure to include .env in your .gitignore file to prevent sensitive information from being uploaded to your repository:
.env
### Step 3: Source the .env File
Source the .env file in your terminal:
```bash
source .env
```
### Step 4: Verify Environment Variables
Use the echo command to verify the variables:
```bash
echo $PRIVATE_KEY
```
### Step 5: Deploy Using Environment Variables
Run the deployment script securely using environment variables, rather than directly specifying the private key:
```bash
forge script script/DeploySimpleStorage.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY 
```
Using this approach ensures better security by keeping sensitive information like private keys out of the command line and your repository.# foundry-fund-me-f25

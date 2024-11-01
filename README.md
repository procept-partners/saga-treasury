# Treasury and Token Deployment Project

## Overview

This project contains Solidity smart contracts and deployment scripts to manage a governance token (`MANA`), utility token (`FYREToken`), and a `Treasury` contract on Ethereum-compatible networks. The project is designed to deploy and manage tokens with features like minting, governance voting, and ownership transfer. The `HelperConfig` contract provides network configuration and helps manage addresses across deployments.

### Contracts

1. **FYREToken** - A utility token used within the ecosystem.
2. **MANA** - A governance token with voting rights for decentralized governance.
3. **Treasury** - Manages assets and controls token minting and governance functions.
4. **HelperConfig** - Manages configuration for different networks and stores addresses of deployed contracts.

## Prerequisites

- **Foundry**: Ensure Foundry is installed. [Installation Guide](https://book.getfoundry.sh/getting-started/installation)
- **Environment Variables**: Set up a `.env` file for local and testnet deployment variables (e.g., deployer keys, token addresses).

## Installation

Clone the repository and install dependencies:

```bash
git clone <your-repo-url>
cd Treasury
forge install
```

## Environment Configuration

Create a `.env` file in the root directory with the following variables. Adjust the values based on your setup:

```plaintext
# Local private key
LOCAL_PRIVATE_KEY=<your-local-private-key>

# Anvil (Local Development) Deployment Variables
ANVIL_FYRE_TOKEN_ADDRESS=0x0000000000000000000000000000000000000000
ANVIL_MANA_TOKEN_ADDRESS=
ANVIL_DEPLOYER_KEY=<your-anvil-private-key>
ANVIL_TREASURY_ADDRESS=0x0000000000000000000000000000000000000000

# Testnet/Aurora variables
PRIVATE_KEY=<your-testnet-private-key>
AURORA_TESTNET_RPC_URL=https://testnet.aurora.dev
```

## Contracts

### FYREToken.sol

- **Purpose**: The `FYREToken` contract is a utility token with minting functionality for distribution within the ecosystem.
- **Constructor Parameters**:
  - `address deployer`: The address of the initial deployer.
  - `uint256 initialSupply`: The initial supply of tokens to mint to the deployer.
- **Functions**:
  - `mint(address to, uint256 amount)`: Allows minting additional tokens.

### MANA.sol

- **Purpose**: The `MANA` contract is a governance token, giving holders voting power within the ecosystem.
- **Constructor Parameters**:
  - `address treasury`: The initial treasury address, which can mint new tokens.
  - `bytes32[] memory defaultPartitions`: Default partitioning for token categorization.
- **Functions**:
  - `mint(address to, uint256 amount, bytes32 partition)`: Mints tokens to the specified address.
  - `allocateGovernanceVotes(address voter, uint256 amount)`: Allocates voting power to token holders.
  - `voteForGovernance(uint256 proposalId, uint256 amount)`: Casts votes for a governance proposal.

### Treasury.sol

- **Purpose**: The `Treasury` contract is designed to hold and manage assets, control token minting, and facilitate governance actions.
- **Constructor Parameters**:
  - Addresses for tokens and authorized signers, along with conversion rates for different assets.
- **Functions**:
  - `transferOwnership(address newOwner)`: Transfers contract ownership to the specified address.

### HelperConfig.sol

- **Purpose**: Stores configuration data for different networks and manages contract addresses.
- **Functions**:
  - `getNetworkConfig(uint256 chainId)`: Returns network configuration based on the chain ID.
  - `setDeployedFYRETokenAddress(address _fyreTokenAddress)`: Sets the address of the deployed `FYREToken`.
  - `setDeployedMANAAddress(address _manaAddress)`: Sets the address of the deployed `MANA`.
  - `setDeployedTreasuryAddress(address _treasuryAddress)`: Sets the address of the deployed `Treasury`.

## Deployment Workflow

The following steps guide you through deploying each contract in the correct order. For local deployments, Anvil is recommended.

## Using `make` Commands for Local and Aurora Testnet Deployment

### Local Deployment

- **Deploy all contracts and transfer ownership locally:**
  ```bash
  make deploy-all-local
  ```
  markdown

# Project Deployment and Testing Instructions

## Deploying Contracts

To deploy contracts locally, use the following `make` commands:

```bash
make deploy-fyre-local
make deploy-mana-local
make deploy-manatoken-local
make deploy-treasury-local
make transfer-ownership-local
make deploy-all-aurora
```
Deploy FYREToken on Aurora Testnet:

```bash
make deploy-fyre-aurora
```
Deploy MANA on Aurora Testnet:

```bash
make deploy-mana-aurora
```
Deploy ManaToken on Aurora Testnet:

```bash
make deploy-manatoken-aurora
```
Deploy Treasury on Aurora Testnet:

```bash
make deploy-treasury-aurora
```
Transfer ownership of all tokens to Treasury on Aurora Testnet:

```bash
make transfer-ownership-aurora
```
Testing
Run the following command to compile and test the contracts:

```bash
forge test
```
License
This project is licensed under the MIT License. See the LICENSE file for details.

Summary
This README.md provides:

Detailed instructions on using make commands for deployments.

Clear organization of contract functions, deployment steps, and testing instructions.

Suitable formatting for readability in a hackathon or professional setting.

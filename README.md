# Mana Token and MANA Token Contracts

## Overview

This repository contains the smart contracts for the Mana Token and MANA Governance Token as part of the SagaHalla cooperative project. The Mana Token is an ERC-20 token used for project-based voting, while the MANA Governance Token is an ERC-1400 token that provides governance rights within the cooperative structure.

## Key Features
* __Mana Token (mana)__
  * __Uncollateralized__
  * __Contributions to Cooperative__: Users can burn Mana tokens to receive collateralized MANA tokens.
  * __Transferable__: Freely transferable among users.
  * __Minting & Burning__: The contract owner can mint new tokens, and users can burn their own tokens.

* __MANA Governance Token (ERC-1400)__
  * __Collateralized__
  * __Restricted Transferability__: Only transfer between allowed parties.
  * __Minting__: Only the contract owner can mint new governance tokens.
  * __Governance Rights__ : Provides governance voting rights proportional to the amount of MANA tokens held, with votes authenticated by the SHLD tokens.
  * __Use Case__: Governance participation, allowing cooperative members to vote on proposals.


## Contract Architecture
# Mana Token and MANA Governance Token Contracts

## 1. Mana Token (ERC-20)
**File**: `ManaToken.sol`

### Constructor
- **Parameters**:
  - `initialSupply`: The initial amount of tokens minted for the deployer.
  -  `manaAddress` : The deployed address of Governance MANA token for conversion of ERC20 --> ERC1400

### Key Functions
- **mint(address to, uint256 amount)**: Allows the contract owner to mint new tokens and assign them to a specified address.
- **contributeToCooperative(uint256 amount)**: Burns the specified amount of Mana tokens from the sender's balance and mints equivalent MANA tokens (using the ERC-1400 contract).
- **burn(uint256 amount)**: Allows users to burn (destroy) their own tokens.
t.

## 2. MANA Governance Token (ERC-1400)
**File**: `MANA.sol`

### Constructor
- **Parameters**:
  - `defaultOperators`: An array of addresses that are allowed to manage tokens on behalf of users.
  - `defaultPartitions`: The partitions (categories) into which the tokens are divided.

### Key Functions
- **mint(address to, uint256 amount)**: Allows the contract owner to mint new governance tokens.
- **allocateGovernanceVotes(address voter, uint256 amount)**: Allocates governance votes to a user based on their token balance.
- **voteForGovernance(uint256 proposalId, uint256 amount)**: Allows users to cast votes for governance proposals based on their governance token holdings.
- **viewGovernanceVotes(uint256 proposalId, address voter)**: Allows users to check how many votes they have cast for a specific governance proposal.


# Deployment

## Setting up the Environment variable
* Create a `.env` file in the root directory with the following content:
```bash
PRIVATE_KEY=your_private_key_here
```


1. Clone the repository
```bash
git clone https://github.com/procept-partners/saga-mana-token.git
cd saga-mana-token
```

2. Install Dependencies
```bash
npm install
```

3. Compile the contracts
```bash
npx hardhat compile
```

4. Deploy on Aurora
(for MANA)
```bash
npx hardhat run ignition/modules/MANA_deploy.js --network auroraTestnet 
```

(for mana)
```bash
npx hardhat run ignition/modules/Manatoken_deploy.js --network auroraTestnet 
```


## Key Points
* The ERC1400 was taken from this repository
[Repository Link](https://github.com/Consensys/UniversalToken)

- The full implementation was not stable, so only some parts were used.

# Testing
* The contracts can be tested with hardhat using this command
```bash
npx hardhat test
```
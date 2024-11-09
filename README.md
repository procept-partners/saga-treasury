
# Saga Treasury

Saga Treasury is a smart contract project that manages treasury functions and token operations using the ERC-1400 standard. This project includes various deployment scripts, token contracts, and the main treasury contract.

## Project Structure

```plaintext
.
├── foundry.toml                 # Foundry configuration file
├── lib
│   ├── forge-std                # Standard Forge library for Solidity tests
│   └── openzeppelin-contracts   # OpenZeppelin contracts for ERC standards
├── Makefile                     # Makefile for automating tasks
├── README.md                    # Project documentation
├── script                       # Deployment and helper scripts
│   ├── HelperConfig.s.sol       # Configuration script
│   ├── Tokens                   # Token-related scripts
│   │   ├── FYRE                 # FYRE Token deployment scripts
│   │   └── MANA                 # MANA Token deployment scripts
│   └── Treasury                 # Treasury deployment scripts
│       ├── DeployOwnershipToTreasury.s.sol
│       └── DeployTreasury.s.sol
└── src                          # Core contract sources
    ├── Tokens                   # Token contracts
    │   ├── ERC1400              # ERC1400 standard contracts
    │   ├── FYREToken.sol        # FYRE token contract
    │   ├── MANA.sol             # MANA token contract
    │   └── ManaToken.sol        # Additional MANA token implementation
    └── Treasury                 # Treasury contract
        └── Treasury.sol         # Core treasury contract
```

## Getting Started

### Prerequisites

Ensure you have the following tools installed:

- [Foundry](https://github.com/gakonst/foundry) - for smart contract development and testing
- [Node.js](https://nodejs.org/) - for scripting, if needed for deployment
- [OpenZeppelin Contracts](https://openzeppelin.com/contracts/) - ERC standard libraries

### Installation

1. Clone the repository:
   
   ```bash
   git clone https://github.com/yourusername/saga-treasury.git
   cd saga-treasury
   ```

2. Install dependencies (e.g., OpenZeppelin contracts) if not already included.

### Compiling Contracts

Use Foundry to compile the contracts:

```bash
forge build
```

### Running Tests

Run tests using Foundry:

```bash
forge test
```

### Deployment

Deployment scripts are located in the `script/` directory. Each script is a Solidity script designed to be run with Foundry or custom deployment tools.

Example: Deploy the Treasury contract:

```bash
forge script script/Treasury/DeployTreasury.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

Replace `<RPC_URL>` and `<PRIVATE_KEY>` with your network RPC URL and private key, respectively.

## Contracts Overview

### Treasury.sol

The `Treasury.sol` contract is the central contract for managing treasury functions. It holds and manages tokens and includes functions for ownership and fund distribution.

### Tokens

- **FYREToken.sol**: Contract implementing the FYRE token.
- **MANA.sol**: Contract for MANA token.
- **ManaToken.sol**: Alternative implementation of the MANA token.
- **ERC1400**: Contains implementations of ERC-1400 standard token functions.

## Scripts Overview

- **HelperConfig.s.sol**: Configuration script for setting up initial values.
- **DeployOwnershipToTreasury.s.sol**: Script to transfer ownership to the Treasury.
- **DeployTreasury.s.sol**: Script to deploy the Treasury contract.

## License

This project is licensed under the terms of the MIT license. See [LICENSE](./LICENSE.txt) for more details.

Note to Redacted Judges: Treasury.sol is the latest development and the central integration point for the frontend.  Integration not yet implemented.


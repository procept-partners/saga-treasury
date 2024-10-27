
# Off-Chain Transaction Signing for Cross-Chain Verification

This document outlines the general approach for securely signing transactions off-chain in a backend environment for **SHLD** and any other tokens that may require cross-chain data verification. The goal is to use off-chain signing for event data originating on **Aurora** and verify it on **NEAR**, ensuring authenticity without exposing private keys in client-side code.

## Overview

Our setup requires **secure signing of transaction data** on the Aurora blockchain, which will then be verified on NEAR. By signing data off-chain in a backend environment, we mitigate the security risks associated with exposing sensitive keys in the front end.

### Key Components
- **Aurora Contract** (e.g., `PurchaseSHLDProxy`): Emits events (e.g., `SHLDPurchaseRecorded`) with hashed transaction data.
- **NEAR Contract** (e.g., `SHLDOwnershipVerifier`): Verifies the signature to confirm data authenticity, enabling cross-chain verification.
- **Backend Service**: Monitors events from Aurora, hashes the data, signs it using a securely stored Ethereum private key, and relays the signed data to NEAR.

## Step-by-Step Implementation

### 1. Set Up the Backend Service for Monitoring and Signing

#### Monitor Events on Aurora
- Use a backend service (e.g., Node.js or Python) to connect to the Aurora blockchain and listen for relevant events emitted by contracts, such as `SHLDPurchaseRecorded`.
- Libraries like **Ethers.js** (JavaScript) or **Web3.py** (Python) are helpful for setting up WebSocket or HTTP listeners.

#### Capture and Hash the Event Data
- When an event (e.g., `SHLDPurchaseRecorded`) is emitted, capture the transaction details (`purchaseId`, `buyer`, `fyreAmount`, `shldAmount`, `timestamp`).
- Generate a data hash using the **Keccak-256** hashing algorithm. This hash should match the format specified in the contract on Aurora.

**Example in JavaScript**:
```javascript
const ethers = require('ethers');
const dataHash = ethers.utils.keccak256(
  ethers.utils.defaultAbiCoder.encode(
    ['uint256', 'address', 'uint256', 'uint256', 'uint256'],
    [purchaseId, buyer, fyreAmount, shldAmount, timestamp]
  )
);
```

#### Sign the Data Hash with the Authorized Ethereum Private Key
- Use the authorized Ethereum private key (typically the contract owner’s key on Aurora) to sign the data hash.

**Example in JavaScript**:
```javascript
const signer = new ethers.Wallet(privateKey);
const signature = await signer.signMessage(ethers.utils.arrayify(dataHash));
```

### 2. Store the Private Key Securely

The Ethereum private key must remain secure to prevent unauthorized access. There are multiple options for managing private keys securely in a backend:

- **Environment Variables**: Store the private key in a secure environment variable and access it directly from your backend service.
- **Cloud Key Management Services (KMS)**:
  - Use **AWS KMS**, **Google Cloud KMS**, or **Azure Key Vault** to store and manage the key. These services provide secure signing operations, so the private key is never exposed in your code.
- **Hardware Security Modules (HSMs)**: For high-security applications, an HSM can securely store private keys and perform signing without ever exposing the key to software.

### 3. Relay Signed Data to NEAR for Verification

Once signed, the backend service should submit the `dataHash`, `signature`, and any additional transaction details (e.g., `fyreAmount`, `shldAmount`, `timestamp`) to the NEAR contract for verification.

#### Submit the Data to NEAR
- Use **NEAR API JS** (or other relevant NEAR libraries) to connect to the NEAR blockchain and submit the signed data to the designated verification function in the `SHLDOwnershipVerifier` contract.

**Example NEAR API JS Code for Submission**:
```javascript
const nearAPI = require("near-api-js");
const { connect, keyStores, WalletConnection } = nearAPI;

const near = await connect(config);
const account = await near.account(nearAccountId);

const result = await account.functionCall({
  contractId: 'shld_contract.testnet',
  methodName: 'verify_ownership',
  args: {
    account_id: buyer,
    fyre_amount: fyreAmount.toString(),
    shld_amount: shldAmount.toString(),
    timestamp: timestamp,
    signature: Array.from(signature) // Convert Uint8Array to an array if needed
  },
});
```

### 4. Verification on NEAR
On NEAR, the `SHLDOwnershipVerifier` contract will:

- **Reconstruct the Data Hash**: Based on the provided transaction details.
- **Verify the Signature**: Using the public key associated with the authorized signer on Aurora.

Upon successful verification, the contract can emit an event or perform an action (e.g., issuing an NFT).

## Security Considerations
- **Keep Private Keys Secure**: Never expose private keys in client-side applications. Always handle signing in a secure backend environment or by using a managed key solution.
- **Monitor and Log**: Log all signing and verification requests, but avoid logging sensitive information like private keys or raw signatures.
- **Rate Limiting**: Implement rate limiting to prevent abuse in cases where multiple signing requests are made.

## Example Use Cases
This approach is useful for:
- **Cross-chain asset transfers** where tokens on one chain need to be verified on another.
- **NFT issuance** for tokens purchased on Aurora but granted on NEAR.
- **Multi-chain governance systems** where voting or governance power is tracked across chains.

With this approach, we ensure that transactions remain verifiable and secure across chains, leveraging off-chain signing in the backend to maintain high security and flexibility.
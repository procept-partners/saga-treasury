
# Using Rainbow Bridge for Cross-Chain Verification of NFT Purchases

This document outlines an alternative approach to off-chain signing, using the **Rainbow Bridge** to verify NFT purchases and cross-chain data authenticity between **Aurora** and **NEAR**. By utilizing Rainbow Bridge for event data transfer, we enable automated cross-chain messaging, offering a secure and decentralized method for cross-chain verification without exposing private keys.

## Overview

The **Rainbow Bridge** enables data transfer between Aurora (Ethereum-compatible) and NEAR, providing a secure, trustless cross-chain solution. This approach allows us to automate the transfer of event data, like `SHLDPurchaseRecorded` emitted on Aurora, to NEAR without relying on off-chain signatures or backend relayers.

### Key Benefits

1. **Automated Cross-Chain Messaging**: The bridge can automatically relay event data between Aurora and NEAR, ensuring that data integrity is maintained.
2. **Increased Security**: The bridge leverages decentralized validators, reducing risks associated with key management or off-chain relaying services.
3. **Trustless Verification on NEAR**: Event data can be directly relayed from Aurora to NEAR for NFT issuance, making the process secure and verifiable on-chain.

### Potential Limitations

1. **Latency and Costs**: Using the Rainbow Bridge introduces some latency for data confirmation on NEAR and incurs cross-chain fees. For frequent, smaller transactions, this can add time and cost.
2. **Custom Messaging Requirements**: Implementing custom event messaging requires encoding event data in a bridge-compatible format and setting up logic on NEAR to process incoming data.
3. **Complexity in Contract Design**: Adjustments to the Aurora contract are necessary to emit events in a format compatible with the bridge, along with NEAR contract changes to verify and handle the incoming data.

## Step-by-Step Approach for Rainbow Bridge Integration

### 1. Modify Aurora Contract for Bridge-Compatible Event Emission

   - Update the `PurchaseSHLDProxy` contract on Aurora to emit events in a format that the Rainbow Bridge can recognize. Include essential information (`buyer`, `fyreAmount`, `shldAmount`, `timestamp`) in the event.

### 2. Bridge Relay and NEAR Verification

   - Configure Rainbow Bridge to monitor and relay these events to NEAR.
   - On NEAR, the `SHLDOwnershipVerifier` contract will listen for incoming messages from the bridge. Upon receiving the data, NEAR’s contract will process it for direct verification and NFT issuance.

## Example Use Case: NFT Issuance for Cross-Chain Transactions

- **Scenario**: A user purchases SHLD on Aurora, and an event with the purchase data is emitted. The Rainbow Bridge then transfers this event to NEAR.
- **Outcome**: NEAR processes this event data for verification, enabling the SHLD token issuance on NEAR automatically without any manual intervention or off-chain signing.

## Summary

Using the Rainbow Bridge for cross-chain verification offers a trustless and automated solution for Aurora-to-NEAR interactions, though it may introduce additional latency and complexity in contract setup. This method eliminates the need for private key management off-chain and ensures secure, direct messaging between chains.

Consider this approach if security and decentralization are critical, and the transaction frequency and delay are acceptable. For real-time or high-frequency transactions, an off-chain signing solution may be more practical.

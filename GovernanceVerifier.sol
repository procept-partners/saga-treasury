// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@aurora-is-near/aurora-bridge/AuroraLightClient.sol";

contract SHLDOwnershipReader {
    address public authorizedSigner;
    AuroraLightClient public auroraLightClient;

    event OwnershipDataReceived(
        string nearAccountId,
        bytes32 tokenHash,
        uint256 timestamp
    );

    constructor(address _authorizedSigner, AuroraLightClient _auroraLightClient) {
        authorizedSigner = _authorizedSigner;
        auroraLightClient = _auroraLightClient;
    }

    // Function to receive and verify ownership proof from NEAR
    function receiveOwnershipProof(
        bytes memory proof
    ) public returns (bool) {
        // Use AuroraLightClient to verify the NEAR proof
        require(
            auroraLightClient.verifyProof(proof),
            "Invalid proof from NEAR"
        );

        // Decode proof data here (this step depends on the actual proof structure)
        (string memory nearAccountId, bytes32 tokenHash) = decodeProofData(proof);

        // Emit event with decoded data
        emit OwnershipDataReceived(nearAccountId, tokenHash, block.timestamp);
        return true;
    }

    function decodeProofData(bytes memory proof) internal pure returns (string memory, bytes32) {
        // Implement the decoding logic according to the proof structure
    }
}


contract SHLDOwnershipVerifier {
    address public authorizedSigner;

    constructor(address _authorizedSigner) {
        authorizedSigner = _authorizedSigner;
    }

    // Verify ownership proof by checking the signature against the authorized signer
    function verifyOwnershipProof(
        string memory nearAccountId,  // NEAR account ID
        bytes32 tokenHash,            // Unique identifier for the SHLD token
        bytes memory signature        // Signature for the ownership proof
    ) public view returns (bool) {
        // Create message hash using the NEAR account ID and specific SHLD token's hash
        bytes32 messageHash = keccak256(abi.encodePacked(nearAccountId, " owns SHLD token ", tokenHash));
        
        // Prefix the hash with "\x19Ethereum Signed Message:\n32" for compatibility with Ethereum's signing method
        bytes32 ethSignedMessageHash = _toEthSignedMessageHash(messageHash);
        
        // Recover the signer from the signature
        address recoveredSigner = _recoverSigner(ethSignedMessageHash, signature);

        // Check if the recovered signer is the authorized signer
        return recoveredSigner == authorizedSigner;
    }

    // Prefix a hash with Ethereum's signed message header to produce a unique hash
    function _toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    // Recover signer address from a message hash and a signature
    function _recoverSigner(bytes32 ethSignedMessageHash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Ensure signature is 65 bytes
        if (signature.length != 65) {
            return (address(0));
        }

        // Extract r, s, and v from the signature
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Perform ecrecover to get the signer's address
        return ecrecover(ethSignedMessageHash, v, r, s);
    }
}

contract AuroraBalancesProof {
    address public authorizedSigner;

    constructor(address _authorizedSigner) {
        authorizedSigner = _authorizedSigner;
    }

    // Event for emitting updated MANA balances for governance tracking, formatted for bridge compatibility
    event GovernanceDataUpdated(
        address indexed holder,
        uint256 manaBalance,
        uint256 manaCollateralBalance,
        uint256 votingPower,
        uint256 timestamp,
        bytes32 proofHash // Hash for verification on the NEAR side
    );

    // Struct for the proof of balances
    struct ManaBalancesProof {
        uint256 mana_balance;                // Governance mana balance
        uint256 collateral_mana_balance;     // Collateralized governance balance
        bytes signature;                     // Signature of the authorized signer
    }

    // Generates and logs a governance data update
    function updateGovernanceData(
        address holder,
        uint256 manaBalance,
        uint256 manaCollateralBalance,
        uint256 votingPower
    ) external {
        require(msg.sender == authorizedSigner, "Only authorized signer can update governance data");

        // Create a proof hash combining governance data (this hash will be part of the event)
        bytes32 proofHash = keccak256(abi.encodePacked(holder, manaBalance, manaCollateralBalance, votingPower, block.timestamp));

        // Emit event with updated governance data and proof hash
        emit GovernanceDataUpdated(holder, manaBalance, manaCollateralBalance, votingPower, block.timestamp, proofHash);
    }
}
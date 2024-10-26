    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
        address public authorizedSigner;  // Address allowed to sign proofs

        constructor(address _authorizedSigner) {
            authorizedSigner = _authorizedSigner;
        }

        // Struct for the proof of balances
        struct ManaBalancesProof {
            uint256 mana_balance;                // Governance mana balance
            uint256 collateral_mana_balance;     // Collateralized governance balance
            bytes signature;                     // Signature of the authorized signer
        }

        // Event for emitting balance proofs
        event BalanceProofGenerated(
            address indexed account,
            uint256 mana_balance,
            uint256 collateral_mana_balance,
            bytes signature
        );

        // Generates a proof of mana and collateral balances for NEAR verification
        function generateManaBalancesProof(
            address account,
            uint256 mana_balance,
            uint256 collateral_mana_balance
        ) public returns (ManaBalancesProof memory) {
            require(msg.sender == authorizedSigner, "Only authorized signer can create proofs");

            // Prepare message hash as required by NEAR (combining account and balances)
            bytes32 messageHash = keccak256(
                abi.encodePacked(account, mana_balance, collateral_mana_balance)
            );

            // Generate the signature for the message hash
            bytes memory signature = _signMessage(messageHash);

            // Emit the proof for off-chain logging and usage
            emit BalanceProofGenerated(account, mana_balance, collateral_mana_balance, signature);

            // Return the proof as a struct
            return ManaBalancesProof({
                mana_balance: mana_balance,
                collateral_mana_balance: collateral_mana_balance,
                signature: signature
            });
        }

        // Internal function to simulate signing the message (replace with actual signing logic)
        function _signMessage(bytes32 messageHash) internal view returns (bytes memory) {
            // NOTE: Replace this placeholder with actual off-chain signing
            // Example placeholder; in production, this should be handled by a secure oracle or private key storage
            bytes memory signature = abi.encodePacked(messageHash);
            return signature;
        }
    }

contract GovernanceData {
    // Address of the contract on NEAR (used for event filtering)
    address public nearCounterpart;

    // Event for governance data updates
    event GovernanceDataUpdated(
        address indexed holder,
        uint256 manaBalance,
        uint256 manaCollateralBalance,
        uint256 votingPower
    );

    constructor(address _nearCounterpart) {
        nearCounterpart = _nearCounterpart;
    }

    // Function to update governance data and emit event
    function updateGovernanceData(
        address holder,
        uint256 manaBalance,
        uint256 manaCollateralBalance,
        uint256 votingPower
    ) external {
        // Emit event with updated governance data
        emit GovernanceDataUpdated(holder, manaBalance, manaCollateralBalance, votingPower);
    }
}

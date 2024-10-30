// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SHLDOwnershipReader {
    using ECDSA for bytes32;

    address public authorizedSigner;

    event OwnershipDataReceived(
        string nearAccountId,
        bytes32 tokenHash,
        uint256 timestamp
    );

    constructor(address _authorizedSigner) {
        authorizedSigner = _authorizedSigner;
    }

    function receiveOwnershipProof(
        string memory nearAccountId,
        bytes32 tokenHash,
        bytes memory signature
    ) public returns (bool) {
        // Create a hash of the data to be signed
        bytes32 messageHash = keccak256(
            abi.encodePacked(nearAccountId, " owns SHLD token ", tokenHash)
        );

        // Convert to Ethereum signed message format
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        // Verify that the signature is from the authorized signer
        address recoveredSigner = ethSignedMessageHash.recover(signature);
        require(recoveredSigner == authorizedSigner, "Invalid signature");

        // Emit event for verified ownership
        emit OwnershipDataReceived(nearAccountId, tokenHash, block.timestamp);
        return true;
    }
}

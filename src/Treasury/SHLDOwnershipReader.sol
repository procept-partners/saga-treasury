// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@aurora-is-near/aurora-bridge/AuroraLightClient.sol";

contract SHLDOwnershipReader {
    address public authorizedSigner;
    AuroraLightClient public auroraLightClient;

    // Event to emit verified ownership data received from NEAR
    event OwnershipDataReceived(
        string nearAccountId,
        bytes32 tokenHash,
        uint256 timestamp
    );

    constructor(
        address _authorizedSigner,
        AuroraLightClient _auroraLightClient
    ) {
        authorizedSigner = _authorizedSigner;
        auroraLightClient = _auroraLightClient;
    }

    // Function to receive and verify ownership proof from NEAR via the bridge
    function receiveOwnershipProof(bytes memory proof) public returns (bool) {
        // Step 1: Verify the proof using AuroraLightClient to ensure authenticity
        require(
            auroraLightClient.verifyProof(proof),
            "Invalid proof from NEAR"
        );

        // Step 2: Decode proof data to retrieve ownership details
        (string memory nearAccountId, bytes32 tokenHash) = decodeProofData(
            proof
        );

        // Step 3: Emit an event to make ownership data available on Aurora
        emit OwnershipDataReceived(nearAccountId, tokenHash, block.timestamp);
        return true;
    }

    // Internal function to decode proof data. Adjust this function based on proof structure.
    function decodeProofData(
        bytes memory proof
    ) internal pure returns (string memory, bytes32) {
        // Assuming the proof data is ABI-encoded with nearAccountId (string) and tokenHash (bytes32)
        // Modify this logic based on the actual proof structure provided by the bridge
        (string memory nearAccountId, bytes32 tokenHash) = abi.decode(
            proof,
            (string, bytes32)
        );

        return (nearAccountId, tokenHash);
    }
}

contract SHLDOwnershipVerifier {
    address public authorizedSigner;

    constructor(address _authorizedSigner) {
        authorizedSigner = _authorizedSigner;
    }

    // Verify ownership proof by checking the signature against the authorized signer
    function verifyOwnershipProof(
        string memory nearAccountId, // NEAR account ID
        bytes32 tokenHash, // Unique identifier for the SHLD token
        bytes memory signature // Signature for the ownership proof
    ) public view returns (bool) {
        // Create message hash using the NEAR account ID and specific SHLD token's hash
        bytes32 messageHash = keccak256(
            abi.encodePacked(nearAccountId, " owns SHLD token ", tokenHash)
        );

        // Prefix the hash with "\x19Ethereum Signed Message:\n32" for compatibility with Ethereum's signing method
        bytes32 ethSignedMessageHash = _toEthSignedMessageHash(messageHash);

        // Recover the signer from the signature
        address recoveredSigner = _recoverSigner(
            ethSignedMessageHash,
            signature
        );

        // Check if the recovered signer is the authorized signer
        return recoveredSigner == authorizedSigner;
    }

    // Prefix a hash with Ethereum's signed message header to produce a unique hash
    function _toEthSignedMessageHash(
        bytes32 hash
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    // Recover signer address from a message hash and a signature
    function _recoverSigner(
        bytes32 ethSignedMessageHash,
        bytes memory signature
    ) internal pure returns (address) {
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

interface IERC1400 {
    function balanceOf(address account) external view returns (uint256);
}

interface IPriceOracle {
    function getPrice(address token) external view returns (uint256);
    function getCombinedMarketCap() external view returns (uint256);
}

contract AuroraBalancesProof {
    address public authorizedSigner;
    address public LAB_CONTRIB;
    address public FIN_CONTRIB;
    IPriceOracle public priceOracle;

    // Event for emitting updated MANA balances for governance tracking, formatted for bridge compatibility
    event GovernanceDataUpdated(
        address indexed holder,
        uint256 manaBalance,
        uint256 manaCollateralBalance,
        uint256 votingPower,
        uint256 timestamp,
        bytes32 proofHash // Hash for verification on the NEAR side
    );

    constructor(
        address _authorizedSigner,
        address _labContrib,
        address _finContrib,
        address _priceOracle
    ) {
        authorizedSigner = _authorizedSigner;
        LAB_CONTRIB = _labContrib;
        FIN_CONTRIB = _finContrib;
        priceOracle = IPriceOracle(_priceOracle);
    }

    // Function to calculate governance voting power based on token holdings and market conditions
    function calculateVotingPower(
        uint256 manaBalance,
        uint256 manaCollateralBalance
    ) internal view returns (uint256) {
        // Step 1: Get current market prices for LAB_CONTRIB and FIN_CONTRIB
        uint256 labPrice = priceOracle.getPrice(LAB_CONTRIB);
        uint256 finPrice = priceOracle.getPrice(FIN_CONTRIB);

        // Step 2: Calculate the market value of the user's tokens
        uint256 labValue = manaBalance * labPrice;
        uint256 finValue = manaCollateralBalance * finPrice;

        // Step 3: Retrieve the combined market cap of LAB_CONTRIB and FIN_CONTRIB
        uint256 combinedMarketCap = priceOracle.getCombinedMarketCap();

        // Step 4: Calculate voting power as a percentage of combined market cap
        return ((labValue + finValue) * 1e18) / combinedMarketCap;
    }

    // Generates and logs a governance data update, including voting power
    function updateGovernanceData(
        address holder,
        uint256 manaBalance,
        uint256 manaCollateralBalance
    ) external {
        require(
            msg.sender == authorizedSigner,
            "Only authorized signer can update governance data"
        );

        // Calculate voting power based on provided balances and current market data
        uint256 votingPower = calculateVotingPower(
            manaBalance,
            manaCollateralBalance
        );

        // Create a proof hash combining governance data for verification
        bytes32 proofHash = keccak256(
            abi.encodePacked(
                holder,
                manaBalance,
                manaCollateralBalance,
                votingPower,
                block.timestamp
            )
        );

        // Emit event with updated governance data, including calculated voting power and proof hash
        emit GovernanceDataUpdated(
            holder,
            manaBalance,
            manaCollateralBalance,
            votingPower,
            block.timestamp,
            proofHash
        );
    }
}

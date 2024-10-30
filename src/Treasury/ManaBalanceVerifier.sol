// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ManaBalanceVerifier {
    // Mana and collateral balances mapping
    mapping(address => uint256) public manaBalances;
    mapping(address => uint256) public collateralManaBalances;

    // Event to emit proof data for use on NEAR
    event BalanceProof(
        address indexed account,
        uint256 manaBalance,
        uint256 collateralManaBalance,
        bytes signature
    );

    // Owner or authorized address to sign proofs
    address private signer;

    constructor(address _signer) {
        signer = _signer;
    }

    // Update mana balances (this would typically be restricted in production)
    function setBalances(
        address account,
        uint256 mana,
        uint256 collateral
    ) public {
        manaBalances[account] = mana;
        collateralManaBalances[account] = collateral;
    }

    // Generate proof of balance
    function generateProof(address account) external returns (bytes memory) {
        uint256 mana = manaBalances[account];
        uint256 collateral = collateralManaBalances[account];

        // Hash the message for proof
        bytes32 messageHash = keccak256(
            abi.encodePacked(account, mana, collateral)
        );

        // Generate a signature (simulated here for example purposes)
        bytes memory signature = abi.encodePacked(messageHash); // Replace with real signature generation

        emit BalanceProof(account, mana, collateral, signature);
        return signature;
    }

    // Public function to retrieve public key or address of signer
    function getSigner() external view returns (address) {
        return signer;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ManaBalanceVerifier {
    using ECDSA for bytes32;

    mapping(address => uint256) public manaBalances;
    mapping(address => uint256) public collateralManaBalances;

    event BalanceProof(
        address indexed account,
        uint256 manaBalance,
        uint256 collateralManaBalance,
        bytes signature
    );

    address private signer;

    constructor(address _signer) {
        signer = _signer;
    }

    function setBalances(
        address account,
        uint256 mana,
        uint256 collateral
    ) public {
        manaBalances[account] = mana;
        collateralManaBalances[account] = collateral;
    }

    function generateProof(
        address account
    ) external view returns (bytes memory) {
        uint256 mana = manaBalances[account];
        uint256 collateral = collateralManaBalances[account];

        bytes32 messageHash = keccak256(
            abi.encodePacked(account, mana, collateral)
        );

        bytes memory signature = messageHash.toEthSignedMessageHash().recover(
            signer
        );

        emit BalanceProof(account, mana, collateral, signature);
        return signature;
    }
}

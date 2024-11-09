// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./ManaToken.sol"; // ERC20 contract
import "./MANA.sol"; // ERC1400 contract

contract ManaConverter is Ownable {
    ManaToken public manaToken; // ERC20 token instance
    MANA public manaERC1400; // ERC1400 token instance
    bytes32 public constant LABOR_CONTRIBUTION = keccak256("labor contribution");

    constructor(ManaToken _manaToken, MANA _manaERC1400) {
        manaToken = _manaToken;
        manaERC1400 = _manaERC1400;
    }

    /**
     * @dev Converts ERC20 mana tokens into ERC1400 MANA tokens in the "labor contribution" partition.
     * Only the contract owner can call this function.
     * The function burns ERC20 tokens from the sender and mints equivalent ERC1400 tokens.
     * @param amount The number of ERC20 tokens to convert.
     */
    function convertToLaborContribution(uint256 amount) external onlyOwner {
        // Step 1: Burn ERC20 tokens from sender
        require(manaToken.balanceOf(msg.sender) >= amount, "Insufficient ERC20 balance");
        manaToken.burn(msg.sender, amount);

        // Step 2: Mint ERC1400 tokens to sender in "labor contribution" partition
        manaERC1400.mint(msg.sender, amount, LABOR_CONTRIBUTION);
    }
}

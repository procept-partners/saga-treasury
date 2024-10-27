// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FyreToken.sol"; // Import the FYRE ERC20 token contract
import "./MANA.sol"; // Import the MANA ERC1400 token contract
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract PurchaseMANA is Ownable {
    FyreToken public fyreToken; // ERC20 FYRE token instance
    MANA public manaToken; // ERC1400 MANA token instance
    bytes32 public constant FINANCIAL_CONTRIBUTION = keccak256("financial contribution");
    uint256 public exchangeRate; // FYRE to MANA exchange rate
    address public treasury; // Treasury wallet to hold FYRE tokens

    /**
     * @dev Initializes the contract with FYRE and MANA token addresses, an exchange rate, and the treasury address.
     * @param _fyreToken Address of the FYRE token contract.
     * @param _manaToken Address of the MANA token contract.
     * @param _exchangeRate Number of MANA tokens per 1 FYRE token.
     * @param _treasury Address of the treasury wallet to receive FYRE tokens.
     */
    constructor(FyreToken _fyreToken, MANA _manaToken, uint256 _exchangeRate, address _treasury) {
        require(_treasury != address(0), "Treasury address cannot be zero");
        fyreToken = _fyreToken;
        manaToken = _manaToken;
        exchangeRate = _exchangeRate;
        treasury = _treasury;
    }

    /**
     * @dev Updates the FYRE-to-MANA exchange rate. Only the owner can call this function.
     * @param newRate New exchange rate as the number of MANA tokens per 1 FYRE token.
     */
    function setExchangeRate(uint256 newRate) external onlyOwner {
        require(newRate > 0, "Exchange rate must be positive");
        exchangeRate = newRate;
    }

    /**
     * @dev Allows users to purchase MANA tokens in the "financial contribution" partition by paying in FYRE tokens.
     * The function transfers FYRE tokens from the sender to the treasury and mints equivalent MANA tokens.
     * @param fyreAmount The amount of FYRE tokens to spend.
     */
    function purchaseMANA(uint256 fyreAmount) external {
        require(fyreToken.balanceOf(msg.sender) >= fyreAmount, "Insufficient FYRE balance");

        // Calculate the amount of MANA tokens to mint based on the exchange rate
        uint256 manaAmount = fyreAmount * exchangeRate;

        // Transfer FYRE tokens from the sender to the treasury wallet
        fyreToken.transferFrom(msg.sender, treasury, fyreAmount);

        // Mint MANA tokens in the "financial contribution" partition to the sender
        manaToken.mint(msg.sender, manaAmount, FINANCIAL_CONTRIBUTION);
    }
}

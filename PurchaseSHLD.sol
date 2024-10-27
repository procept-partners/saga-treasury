// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FyreToken.sol"; // Import the FYRE ERC20 token contract
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract PurchaseSHLDProxy is Ownable {
    using ECDSA for bytes32;

    FyreToken public fyreToken; // ERC20 FYRE token instance
    address public treasury; // Treasury wallet to hold received FYRE tokens
    uint256 public exchangeRate; // FYRE to SHLD exchange rate
    uint256 public purchaseCounter; // Unique identifier for each purchase

    // Event to log SHLD purchases for cross-chain processing, with data hash for off-chain signing
    event SHLDPurchaseRecorded(
        uint256 indexed purchaseId,     // Unique purchase identifier
        address indexed buyer,          // Address of the buyer
        uint256 fyreAmount,             // Amount of FYRE spent
        uint256 shldAmount,             // Amount of SHLD tokens purchased
        uint256 timestamp,              // Timestamp of the purchase
        bytes32 dataHash                // Hash of the purchase data
    );

    /**
     * @dev Initializes the contract with the FYRE token address, an exchange rate, and the treasury address.
     * @param _fyreToken Address of the FYRE token contract.
     * @param _exchangeRate Number of SHLD tokens per 1 FYRE token.
     * @param _treasury Address of the treasury wallet to receive FYRE tokens.
     */
    constructor(FyreToken _fyreToken, uint256 _exchangeRate, address _treasury) {
        require(_treasury != address(0), "Treasury address cannot be zero");

        fyreToken = _fyreToken;
        exchangeRate = _exchangeRate;
        treasury = _treasury;
        purchaseCounter = 0; // Initialize purchase counter
    }

    /**
     * @dev Updates the FYRE-to-SHLD exchange rate. Only the owner can call this function.
     * @param newRate New exchange rate as the number of SHLD tokens per 1 FYRE token.
     */
    function setExchangeRate(uint256 newRate) external onlyOwner {
        require(newRate > 0, "Exchange rate must be positive");
        exchangeRate = newRate;
    }

    /**
     * @dev Allows users to purchase SHLD tokens by paying in FYRE tokens.
     * The function transfers FYRE tokens from the sender to the treasury and logs the purchase details.
     * @param fyreAmount The amount of FYRE tokens to spend.
     */
    function purchaseSHLD(uint256 fyreAmount) external {
        require(fyreToken.balanceOf(msg.sender) >= fyreAmount, "Insufficient FYRE balance");

        // Calculate the number of SHLD tokens equivalent to the provided FYRE amount
        uint256 shldAmount = fyreAmount * exchangeRate;

        // Transfer FYRE tokens from the sender to the treasury wallet
        fyreToken.transferFrom(msg.sender, treasury, fyreAmount);

        // Increment the purchase counter for a unique purchase ID
        purchaseCounter++;

        // Generate the data hash for off-chain signing
        bytes32 dataHash = keccak256(
            abi.encodePacked(purchaseCounter, msg.sender, fyreAmount, shldAmount, block.timestamp)
        );

        // Emit the purchase event with the data hash
        emit SHLDPurchaseRecorded(
            purchaseCounter,
            msg.sender,
            fyreAmount,
            shldAmount,
            block.timestamp,
            dataHash
        );
    }
}


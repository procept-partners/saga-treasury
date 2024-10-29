// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FYREToken} from "../Tokens/FYREToken.sol"; // Import the FYRE ERC20 token contract
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract PurchaseFYRE is Ownable {
    FyreToken public fyreToken; // ERC20 FYRE token instance
    IERC20 public usdcToken; // ERC20 USDC token instance
    IERC20 public tbtcToken; // ERC20 tBTC token instance
    address public treasury; // Treasury wallet to hold received tokens

    // Exchange rates (per token) for FYRE
    uint256 public usdcToFyreRate; // FYRE per USDC
    uint256 public ethToFyreRate; // FYRE per ETH
    uint256 public tbtcToFyreRate; // FYRE per tBTC

    /**
     * @dev Initializes the contract with token addresses, initial exchange rates, and the treasury address.
     * @param _fyreToken Address of the FYRE token contract.
     * @param _usdcToken Address of the USDC token contract.
     * @param _tbtcToken Address of the tBTC token contract.
     * @param _usdcToFyreRate FYRE per USDC rate.
     * @param _ethToFyreRate FYRE per ETH rate.
     * @param _tbtcToFyreRate FYRE per tBTC rate.
     * @param _treasury Address of the treasury wallet to receive payment tokens.
     */
    constructor(
        FyreToken _fyreToken,
        IERC20 _usdcToken,
        IERC20 _tbtcToken,
        uint256 _usdcToFyreRate,
        uint256 _ethToFyreRate,
        uint256 _tbtcToFyreRate,
        address _treasury
    ) {
        require(_treasury != address(0), "Treasury address cannot be zero");

        fyreToken = _fyreToken;
        usdcToken = _usdcToken;
        tbtcToken = _tbtcToken;
        usdcToFyreRate = _usdcToFyreRate;
        ethToFyreRate = _ethToFyreRate;
        tbtcToFyreRate = _tbtcToFyreRate;
        treasury = _treasury;
    }

    /**
     * @dev Updates the exchange rates for FYRE purchases. Only the owner can call this function.
     * @param newUsdcRate New FYRE per USDC rate.
     * @param newEthRate New FYRE per ETH rate.
     * @param newTbtcRate New FYRE per tBTC rate.
     */
    function setExchangeRates(
        uint256 newUsdcRate,
        uint256 newEthRate,
        uint256 newTbtcRate
    ) external onlyOwner {
        require(
            newUsdcRate > 0 && newEthRate > 0 && newTbtcRate > 0,
            "Rates must be positive"
        );
        usdcToFyreRate = newUsdcRate;
        ethToFyreRate = newEthRate;
        tbtcToFyreRate = newTbtcRate;
    }

    /**
     * @dev Allows users to purchase FYRE tokens by paying in USDC.
     * @param usdcAmount The amount of USDC tokens to spend.
     */
    function purchaseFYREWithUSDC(uint256 usdcAmount) external {
        uint256 fyreAmount = usdcAmount * usdcToFyreRate;
        require(
            usdcToken.balanceOf(msg.sender) >= usdcAmount,
            "Insufficient USDC balance"
        );

        // Transfer USDC tokens to the treasury
        usdcToken.transferFrom(msg.sender, treasury, usdcAmount);

        // Mint FYRE tokens to the sender
        fyreToken.mint(msg.sender, fyreAmount);
    }

    /**
     * @dev Allows users to purchase FYRE tokens by paying in tBTC.
     * @param tbtcAmount The amount of tBTC tokens to spend.
     */
    function purchaseFYREWithTBTC(uint256 tbtcAmount) external {
        uint256 fyreAmount = tbtcAmount * tbtcToFyreRate;
        require(
            tbtcToken.balanceOf(msg.sender) >= tbtcAmount,
            "Insufficient tBTC balance"
        );

        // Transfer tBTC tokens to the treasury
        tbtcToken.transferFrom(msg.sender, treasury, tbtcAmount);

        // Mint FYRE tokens to the sender
        fyreToken.mint(msg.sender, fyreAmount);
    }

    /**
     * @dev Allows users to purchase FYRE tokens by paying in ETH.
     */
    function purchaseFYREWithETH() external payable {
        uint256 ethAmount = msg.value;
        uint256 fyreAmount = ethAmount * ethToFyreRate;

        require(ethAmount > 0, "No ETH sent");

        // Transfer ETH to the treasury
        (bool success, ) = treasury.call{value: ethAmount}("");
        require(success, "ETH transfer failed");

        // Mint FYRE tokens to the sender
        fyreToken.mint(msg.sender, fyreAmount);
    }

    // Accepts ETH deposits
    receive() external payable {}
}

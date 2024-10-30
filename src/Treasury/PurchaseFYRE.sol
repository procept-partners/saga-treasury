// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FYREToken} from "../Tokens/FYREToken.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract PurchaseFYRE is Ownable {
    FyreToken public fyreToken; // ERC20 FYRE token instance
    IERC20 public usdcToken; // ERC20 USDC token instance
    IERC20 public wbtcToken; // ERC20 wbtc token instance
    address public treasury; // Treasury wallet to hold received tokens

    // Exchange rates (per token) for FYRE
    uint256 public usdcToFyreRate; // FYRE per USDC
    uint256 public ethToFyreRate; // FYRE per ETH
    uint256 public wbtcToFyreRate; // FYRE per wbtc

    /**
     * @dev Initializes the contract with token addresses, initial exchange rates, and the treasury address.
     * @param _fyreToken Address of the FYRE token contract.
     * @param _usdcToken Address of the USDC token contract.
     * @param _wbtcToken Address of the wbtc token contract.
     * @param _usdcToFyreRate FYRE per USDC rate.
     * @param _ethToFyreRate FYRE per ETH rate.
     * @param _wbtcToFyreRate FYRE per wbtc rate.
     * @param _treasury Address of the treasury wallet to receive payment tokens.
     */
    constructor(
        FyreToken _fyreToken,
        IERC20 _usdcToken,
        IERC20 _wbtcToken,
        uint256 _usdcToFyreRate,
        uint256 _ethToFyreRate,
        uint256 _wbtcToFyreRate,
        address _treasury
    ) {
        require(_treasury != address(0), "Treasury address cannot be zero");

        fyreToken = _fyreToken;
        usdcToken = _usdcToken;
        wbtcToken = _wbtcToken;
        usdcToFyreRate = _usdcToFyreRate;
        ethToFyreRate = _ethToFyreRate;
        wbtcToFyreRate = _wbtcToFyreRate;
        treasury = _treasury;
    }

    /**
     * @dev Updates the exchange rates for FYRE purchases. Only the owner can call this function.
     * @param newUsdcRate New FYRE per USDC rate.
     * @param newEthRate New FYRE per ETH rate.
     * @param newwBtcRate New FYRE per wbtc rate.
     */
    function setExchangeRates(
        uint256 newUsdcRate,
        uint256 newEthRate,
        uint256 newWbtcRate
    ) external onlyOwner {
        require(
            newUsdcRate > 0 && newEthRate > 0 && newWbtcRate > 0,
            "Rates must be positive"
        );
        usdcToFyreRate = newUsdcRate;
        ethToFyreRate = newEthRate;
        wbtcToFyreRate = newWbtcRate;
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
     * @dev Allows users to purchase FYRE tokens by paying in wbtc.
     * @param wbtcAmount The amount of wBTC tokens to spend.
     */
    function purchaseFYREWithwBTC(uint256 wbtcAmount) external {
        uint256 fyreAmount = wbtcAmount * wbtcToFyreRate;
        require(
            wbtcToken.balanceOf(msg.sender) >= wbtcAmount,
            "Insufficient wBTC balance"
        );

        // Transfer wBTC tokens to the treasury
        wbtcToken.transferFrom(msg.sender, treasury, wbtcAmount);

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

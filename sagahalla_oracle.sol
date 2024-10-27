// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IPriceOracle {
    function getPrice(address token) external view returns (uint256);
    function getCombinedMarketCap() external view returns (uint256);
}

contract GenesisPriceOracle is IPriceOracle, Ownable {
    // Token addresses for FYRE, MANA ERC20, LAB_CONTRIB, FIN_CONTRIB, and SHLD
    address public FYRE;
    address public MANA_ERC20;
    address public LAB_CONTRIB;
    address public FIN_CONTRIB;
    address public SHLD;

    // Fixed prices for Round 0 (genesis round)
    mapping(address => uint256) private tokenPrices;
    uint256 public combinedMarketCap;

    constructor(
        address _fyre,
        address _manaERC20,
        address _labContrib,
        address _finContrib,
        address _shld,
        uint256 _fyrePrice,
        uint256 _manaERC20Price,
        uint256 _labContribPrice,
        uint256 _finContribPrice,
        uint256 _shldPrice
    ) {
        // Assign token addresses
        FYRE = _fyre;
        MANA_ERC20 = _manaERC20;
        LAB_CONTRIB = _labContrib;
        FIN_CONTRIB = _finContrib;
        SHLD = _shld;

        // Set fixed prices for each token
        tokenPrices[FYRE] = _fyrePrice;
        tokenPrices[MANA_ERC20] = _manaERC20Price;
        tokenPrices[LAB_CONTRIB] = _labContribPrice;
        tokenPrices[FIN_CONTRIB] = _finContribPrice;
        tokenPrices[SHLD] = _shldPrice;

        // Calculate and store the combined market cap
        combinedMarketCap = _fyrePrice + _manaERC20Price + _labContribPrice + _finContribPrice + _shldPrice;
    }

    // Function to get the price of a specific token
    function getPrice(address token) external view override returns (uint256) {
        require(tokenPrices[token] > 0, "Token price not available");
        return tokenPrices[token];
    }

    // Function to get the combined market cap for all tokens
    function getCombinedMarketCap() external view override returns (uint256) {
        return combinedMarketCap;
    }

    // Optional function to update token prices if needed (restricted to owner)
    function updateTokenPrice(address token, uint256 newPrice) external onlyOwner {
        require(tokenPrices[token] > 0, "Token not supported");
        combinedMarketCap = combinedMarketCap - tokenPrices[token] + newPrice;
        tokenPrices[token] = newPrice;
    }
}

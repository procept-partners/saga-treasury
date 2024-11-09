// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IPriceOracle {
    function getPrice(address token, bytes32 partition) external view returns (uint256);
    function getCombinedMarketCap() external view returns (uint256);
}

contract GenesisPriceOracle is IPriceOracle, Ownable {
    // Token addresses
    address public immutable FYRE;
    address public immutable manaERC20;
    address public immutable MANA;

    // Define partition constants
    bytes32 public constant LABOR_CONTRIBUTION = keccak256("labor contribution");
    bytes32 public constant FINANCIAL_CONTRIBUTION = keccak256("financial contribution");

    // Prices for each token and partition
    uint256 public fyrePrice;
    uint256 public manaERC20Price;
    mapping(bytes32 => uint256) public manaPartitionPrices;

    uint256 public combinedMarketCap;

    // Event to track price updates
    event TokenPriceUpdated(address indexed token, bytes32 indexed partition, uint256 newPrice);

    constructor(
        address _fyre,
        address _manaERC20,
        address _manaERC1400,
        uint256 _fyrePrice,
        uint256 _manaERC20Price,
        uint256 _manaLaborPrice,
        uint256 _manaFinancialPrice
    ) {
        // Assign token addresses
        FYRE = _fyre;
        manaERC20 = _manaERC20;
        MANA = _manaERC1400;

        // Set initial prices
        fyrePrice = _fyrePrice;
        manaERC20Price = _manaERC20Price;
        manaPartitionPrices[LABOR_CONTRIBUTION] = _manaLaborPrice;
        manaPartitionPrices[FINANCIAL_CONTRIBUTION] = _manaFinancialPrice;

        // Calculate combined market cap
        combinedMarketCap = _fyrePrice + _manaERC20Price + _manaLaborPrice + _manaFinancialPrice;
    }

    /**
     * @dev Get the price of a specific token. For MANA, specify a partition (LABOR_CONTRIBUTION or FINANCIAL_CONTRIBUTION).
     */
    function getPrice(address token, bytes32 partition) external view override returns (uint256) {
        if (token == FYRE) {
            return fyrePrice;
        } else if (token == manaERC20) {
            return manaERC20Price;
        } else if (token == MANA) {
            require(
                isValidPartition(partition),
                "Invalid partition"
            );
            return manaPartitionPrices[partition];
        } else {
            revert("Token not supported");
        }
    }

    /**
     * @dev Get the combined market cap for FYRE, mana (ERC20), and both partitions of MANA (ERC1400).
     */
    function getCombinedMarketCap() external view override returns (uint256) {
        return combinedMarketCap;
    }

    /**
     * @dev Update the price of a specific token. For MANA, specify the partition.
     */
    function updateTokenPrice(address token, bytes32 partition, uint256 newPrice) external onlyOwner {
        uint256 oldPrice;

        if (token == FYRE) {
            oldPrice = fyrePrice;
            fyrePrice = newPrice;
            emit TokenPriceUpdated(token, bytes32(0), newPrice);
        } else if (token == manaERC20) {
            oldPrice = manaERC20Price;
            manaERC20Price = newPrice;
            emit TokenPriceUpdated(token, bytes32(0), newPrice);
        } else if (token == MANA) {
            require(
                isValidPartition(partition),
                "Invalid partition"
            );
            oldPrice = manaPartitionPrices[partition];
            manaPartitionPrices[partition] = newPrice;
            emit TokenPriceUpdated(token, partition, newPrice);
        } else {
            revert("Token not supported");
        }

        // Update combined market cap
        combinedMarketCap = combinedMarketCap - oldPrice + newPrice;
    }

    /**
     * @dev Checks if a partition is valid.
     */
    function isValidPartition(bytes32 partition) internal pure returns (bool) {
        return (partition == LABOR_CONTRIBUTION || partition == FINANCIAL_CONTRIBUTION);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1400.sol"; // Import the ERC1400 contract
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MANA is ERC1400 {
    using SafeMath for uint256;

    // Define partition constants
    bytes32 public constant LABOR_CONTRIBUTION = keccak256("labor contribution");
    bytes32 public constant FINANCIAL_CONTRIBUTION = keccak256("financial contribution");

    // Events for transparency
    event PartitionCollateralized(address indexed from, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount, bytes32 partition);

    constructor()
        ERC1400("Collateralized MANA", "MANA", _defaultPartitions())
    {}

    /**
     * @dev Sets default partitions for the contract.
     * This function is private and called only once at deployment.
     */
    function _defaultPartitions() private pure returns (bytes32[] memory partitions) {
        partitions = new bytes32 Initialize array with two elements
        partitions[0] = LABOR_CONTRIBUTION;
        partitions[1] = FINANCIAL_CONTRIBUTION;
        return partitions;
    }

    /**
     * @dev Mints tokens in a specified partition.
     * Only the owner can call this function.
     * @param to The address to receive the minted tokens.
     * @param amount The number of tokens to mint.
     * @param partition The partition for the minted tokens, either "labor contribution" or "financial contribution".
     */
    function mint(address to, uint256 amount, bytes32 partition) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(
            partition == LABOR_CONTRIBUTION || partition == FINANCIAL_CONTRIBUTION,
            "Invalid partition"
        );
        _issue(msg.sender, to, amount, partition); 
    }

    /**
     * @dev Burns tokens from the "labor contribution" partition for a specified address.
     * Only the owner can call this function.
     * @param from The address whose tokens will be burned.
     * @param amount The number of tokens to burn.
     */
    function burnFromLaborContribution(address from, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(
            _balanceOfByPartition[from][LABOR_CONTRIBUTION] >= amount,
            "Insufficient balance in labor contribution partition"
        );

        // Reduce the partition-specific balance and total supply of that partition
        _balanceOfByPartition[from][LABOR_CONTRIBUTION] = _balanceOfByPartition[from][LABOR_CONTRIBUTION].sub(amount);
        _totalSupplyByPartition[LABOR_CONTRIBUTION] = _totalSupplyByPartition[LABOR_CONTRIBUTION].sub(amount);

        // Reduce the general balance and total supply
        _balances[from] = _balances[from].sub(amount);
        _totalSupply = _totalSupply.sub(amount);

        emit TokensBurned(from, amount, LABOR_CONTRIBUTION);
    }

    /**
     * @dev Converts tokens from the "labor contribution" partition to the "financial contribution" partition.
     * Only the owner can call this function.
     * @param from The address whose tokens will be collateralized.
     * @param amount The number of tokens to transfer between partitions.
     */
    function collateralizeLaborContribution(address from, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(
            _balanceOfByPartition[from][LABOR_CONTRIBUTION] >= amount,
            "Insufficient balance in labor contribution partition"
        );

        // Reduce the balance in the labor contribution partition
        _balanceOfByPartition[from][LABOR_CONTRIBUTION] = _balanceOfByPartition[from][LABOR_CONTRIBUTION].sub(amount);
        _totalSupplyByPartition[LABOR_CONTRIBUTION] = _totalSupplyByPartition[LABOR_CONTRIBUTION].sub(amount);

        // Increase the balance in the financial contribution partition
        _balanceOfByPartition[from][FINANCIAL_CONTRIBUTION] = _balanceOfByPartition[from][FINANCIAL_CONTRIBUTION].add(amount);
        _totalSupplyByPartition[FINANCIAL_CONTRIBUTION] = _totalSupplyByPartition[FINANCIAL_CONTRIBUTION].add(amount);

        emit PartitionCollateralized(from, amount);
    }
}

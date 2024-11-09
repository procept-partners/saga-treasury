// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC1400 is IERC20, Ownable {
    using SafeMath for uint256;

    // Token information
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    // Standard ERC20 balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Partitioned token balances
    bytes32[] private _totalPartitions;
    mapping(bytes32 => uint256) private _totalSupplyByPartition;
    mapping(address => mapping(bytes32 => uint256)) private _balanceOfByPartition;

    // Event for issuing tokens to specific partition
    event Issued(address indexed operator, address indexed to, uint256 value, bytes32 partition);

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        bytes32[] memory defaultPartitions
    ) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _totalPartitions = defaultPartitions;
    }

    // Basic ERC20 functions
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "Invalid address");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Allowance exceeded");

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(amount);
        emit Transfer(from, to, amount);
        return true;
    }

    // Partitioned token issuance
    function issueToPartition(bytes32 partition, address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid address");

        _balanceOfByPartition[to][partition] = _balanceOfByPartition[to][partition].add(amount);
        _totalSupplyByPartition[partition] = _totalSupplyByPartition[partition].add(amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[to] = _balances[to].add(amount);

        emit Issued(msg.sender, to, amount, partition);
        emit Transfer(address(0), to, amount); // Transfer event for minting
    }

    // Restricted transfer within partitions
    function restrictedTransfer(address from, address to, uint256 amount, bytes32 partition) external onlyOwner returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balanceOfByPartition[from][partition] >= amount, "Insufficient balance in partition");

        // Perform the transfer within the specified partition
        _balanceOfByPartition[from][partition] = _balanceOfByPartition[from][partition].sub(amount);
        _balanceOfByPartition[to][partition] = _balanceOfByPartition[to][partition].add(amount);

        // Update general balance tracking as well
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);

        emit Transfer(from, to, amount);
        return true;
    }

    function balanceOfByPartition(address account, bytes32 partition) external view returns (uint256) {
        return _balanceOfByPartition[account][partition];
    }

    function totalSupplyByPartition(bytes32 partition) external view returns (uint256) {
        return _totalSupplyByPartition[partition];
    }
}

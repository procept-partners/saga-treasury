// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Math} from "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ERC1400 is IERC20, Ownable {
    using Math for uint256;

    // Token information
    string internal _name;
    string internal _symbol;
    uint256 internal _totalSupply;

    // Mapping from token holder to balance
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    // Mapping from (tokenHolder, spender) to allowed value
    mapping(address => mapping(address => uint256)) internal _allowed;

    // List of partitions
    bytes32[] internal _totalPartitions;

    // Mapping from partition to total supply of that partition
    mapping(bytes32 => uint256) internal _totalSupplyByPartition;

    // Mapping from (tokenHolder, partition) to balance of corresponding partition
    mapping(address => mapping(bytes32 => uint256))
        internal _balanceOfByPartition;

    // Default partitions
    bytes32[] internal _defaultPartitions;

    // Event for issuing tokens
    event Issued(
        address indexed operator,
        address indexed to,
        uint256 value,
        bytes32 partition
    );

    // Constructor
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        bytes32[] memory defaultPartitions
    ) Ownable(msg.sender) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _defaultPartitions = defaultPartitions;
    }

    // ERC20 standard functions
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address owner) external view override returns (uint256) {
        return _balances[owner];
    }

    function transfer(
        address to,
        uint256 value
    ) external override returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balances[msg.sender] >= value, "Insufficient balance");

        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(
        address spender,
        uint256 value
    ) external override returns (bool) {
        require(spender != address(0), "Invalid address");
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balances[from] >= value, "Insufficient balance");
        require(_allowed[from][msg.sender] >= value, "Allowance exceeded");

        _balances[from] -= value;
        _balances[to] += value;
        _allowed[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    // Restricted transfer implementation
    function restrictedTransfer(
        address from,
        address to,
        uint256 value,
        bytes32 partition
    ) external onlyOwner returns (bool) {
        require(to != address(0), "Invalid address");
        require(
            _balanceOfByPartition[from][partition] >= value,
            "Insufficient balance in partition"
        );

        _balanceOfByPartition[from][partition] -= value;
        _balanceOfByPartition[to][partition] += value;
        emit Transfer(from, to, value);
        return true;
    }

    // Issue tokens to a specific partition
    function _issue(
        address operator,
        address to,
        uint256 value,
        bytes32 partition
    ) internal {
        require(to != address(0), "Invalid address");

        // Update balances
        _balanceOfByPartition[to][partition] += value;
        _totalSupplyByPartition[partition] += value;
        _totalSupply += value;

        emit Issued(operator, to, value, partition);
    }

    // Issue tokens to a specific partition via external function
    function issueToPartition(
        bytes32 partition,
        address to,
        uint256 value
    ) external onlyOwner {
        _issue(msg.sender, to, value, partition);
    }

    // Partition management functions
    function addPartition(bytes32 partition) external onlyOwner {
        require(
            _totalSupplyByPartition[partition] == 0,
            "Partition already exists"
        );
        _totalPartitions.push(partition);
    }

    function totalSupplyByPartition(
        bytes32 partition
    ) external view returns (uint256) {
        return _totalSupplyByPartition[partition];
    }

    // View balance of a specific partition
    function balanceOfByPartition(
        address tokenHolder,
        bytes32 partition
    ) external view returns (uint256) {
        return _balanceOfByPartition[tokenHolder][partition];
    }
}

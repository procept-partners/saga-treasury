// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MANA} from "./MANA.sol";

contract ManaToken is ERC20, Ownable {
    MANA public manaGovernanceToken;
    address public treasury;

    // Declare the mappings for vote allocations and project votes
    mapping(address => uint256) public allocateVotes;
    mapping(uint256 => mapping(address => uint256)) public voteForProject;

    constructor(
        uint256 initialSupply,
        address manaAddress,
        address _treasury
    ) ERC20("Uncollateralized Mana", "mana") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
        manaGovernanceToken = MANA(manaAddress);
        treasury = _treasury;
    }

    modifier onlyTreasury() {
        require(msg.sender == treasury, "Only Treasury can call this function");
        _;
    }

    function allocateVotesToVoter(
        address voter,
        uint256 amount
    ) external onlyTreasury {
        require(balanceOf(voter) >= amount, "Insufficient Mana balance");
        allocateVotes[voter] += amount;
    }

    function recordProjectVote(uint256 projectId, uint256 amount) external {
        require(
            allocateVotes[msg.sender] >= amount,
            "Not enough allocated votes"
        );
        allocateVotes[msg.sender] -= amount;
        voteForProject[projectId][msg.sender] += amount;
    }
}

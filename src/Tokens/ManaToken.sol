// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MANA} from "./MANA.sol"; // Import the ERC1400 MANA contract

contract ManaToken is ERC20, Ownable {
    mapping(address => uint256) public allocatedVotes;
    mapping(uint256 => mapping(address => uint256)) public projectVotes;
    MANA public manaGovernanceToken; // Reference to the MANA ERC-1400 token

    constructor(
        uint256 initialSupply,
        address manaAddress
    ) ERC20("Uncollateralized Mana", "mana") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
        manaGovernanceToken = MANA(manaAddress); // Initialize MANA contract
    }

    function contributeToCooperative(uint256 amount) external {
        _burn(msg.sender, amount);
        bytes32 defaultPartition = "";
        manaGovernanceToken.mint(msg.sender, amount, defaultPartition);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function allocateVotes(address voter, uint256 amount) external onlyOwner {
        require(balanceOf(voter) >= amount, "Insufficient Mana balance");
        allocatedVotes[voter] += amount;
    }

    function voteForProject(uint256 projectId, uint256 amount) external {
        require(
            allocatedVotes[msg.sender] >= amount,
            "Not enough allocated votes"
        );
        allocatedVotes[msg.sender] -= amount;
        projectVotes[projectId][msg.sender] += amount;
    }

    function allocatedMana(address voter) public view returns (uint256) {
        return allocatedVotes[voter];
    }

    function viewVotes(
        uint256 projectId,
        address voter
    ) external view returns (uint256) {
        return projectVotes[projectId][voter];
    }
}

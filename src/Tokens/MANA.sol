// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1400} from "./ERC1400/ERC1400.sol"; // Import the ERC1400
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract MANA is ERC1400 {
    using Math for uint256;

    mapping(address => uint256) public governanceVotes;
    mapping(uint256 => mapping(address => uint256)) public governanceProposals;
    event GovernanceVoteAllocated(address indexed voter, uint256 amount);

    constructor(
        address[] memory defaultOperators,
        bytes32[] memory defaultPartitions
    ) ERC1400("Collateralized MANA", "MANA", defaultPartitions) {}

    function mint(
        address to,
        uint256 amount,
        bytes32 partition
    ) external onlyOwner {
        address operator = msg.sender;
        _issue(operator, to, amount, partition);
    }

    // Allocate governance votes
    function allocateGovernanceVotes(
        address voter,
        uint256 amount
    ) external onlyOwner {
        require(
            this.balanceOf(voter) >= amount,
            "Insufficient Governance MANA"
        );
        governanceVotes[voter] += amount;
        emit GovernanceVoteAllocated(voter, amount);
    }

    // Function to vote for governance proposals
    function voteForGovernance(uint256 proposalId, uint256 amount) external {
        require(
            governanceVotes[msg.sender] >= amount,
            "Not enough governance votes"
        );
        governanceVotes[msg.sender] -= amount;
        governanceProposals[proposalId][msg.sender] += amount;
    }

    // View governance votes for a specific proposal
    function viewGovernanceVotes(
        uint256 proposalId,
        address voter
    ) external view returns (uint256) {
        return governanceProposals[proposalId][voter];
    }
}

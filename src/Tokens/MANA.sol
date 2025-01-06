// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1400} from "./ERC1400/ERC1400.sol"; // Import the ERC1400
import {Math} from "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract MANA is ERC1400 {
    using Math for uint256;
    address public treasury;

    mapping(address => uint256) public governanceVotes;
    mapping(uint256 => mapping(address => uint256)) public governanceProposals;
    event GovernanceVoteAllocated(address indexed voter, uint256 amount);

    constructor(
        address _treasury,
        bytes32[] memory defaultPartitions
    ) ERC1400("Collateralized MANA", "MANA", defaultPartitions) {
        treasury = _treasury;
    }

    modifier onlyTreasury() {
        require(msg.sender == treasury, "Only Treasury can call this function");
        _;
    }

    function mint(
        address to,
        uint256 amount,
        bytes32 partition
    ) external onlyTreasury {
        _issue(msg.sender, to, amount, partition);
    }

    function allocateGovernanceVotes(
        address voter,
        uint256 amount
    ) external onlyTreasury {
        require(
            this.balanceOf(voter) >= amount,
            "Insufficient Governance MANA"
        );
        governanceVotes[voter] += amount;
        emit GovernanceVoteAllocated(voter, amount);
    }

    function voteForGovernance(uint256 proposalId, uint256 amount) external {
        require(
            governanceVotes[msg.sender] >= amount,
            "Not enough governance votes"
        );
        governanceVotes[msg.sender] -= amount;
        governanceProposals[proposalId][msg.sender] += amount;
    }

    function viewGovernanceVotes(
        uint256 proposalId,
        address voter
    ) external view returns (uint256) {
        return governanceProposals[proposalId][voter];
    }
}

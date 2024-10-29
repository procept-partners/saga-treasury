// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {MANA} from "src/Tokens/MANA.sol";

contract MANATest is Test {
    MANA mana;
    address owner;
    address addr1;
    address addr2;

    bytes32 partition = keccak256("partition1");

    function setUp() public {
        owner = address(this); // Default test contract as owner
        addr1 = address(0x123);
        addr2 = address(0x456);

        // Deploy MANA contract
        address;
        defaultOperators[0] = owner;

        bytes32;
        defaultPartitions[0] = partition;

        mana = new MANA(defaultOperators, defaultPartitions);

        // Mint initial tokens to addr1
        mana.mint(addr1, 1000, partition);
    }

    function testOwnerCanMintTokens() public {
        mana.mint(addr1, 1000, partition);
        assertEq(mana.balanceOf(addr1), 2000);
    }

    function testNonOwnerCannotMintTokens() public {
        vm.prank(addr1);
        vm.expectRevert("Ownable: caller is not the owner");
        mana.mint(addr1, 1000, partition);
    }

    function testOwnerCanAllocateGovernanceVotes() public {
        mana.allocateGovernanceVotes(addr1, 500);
        uint256 votes = mana.governanceVotes(addr1);
        assertEq(votes, 500);
    }

    function testNonOwnerCannotAllocateGovernanceVotes() public {
        vm.prank(addr1);
        vm.expectRevert("Ownable: caller is not the owner");
        mana.allocateGovernanceVotes(addr1, 500);
    }

    function testAllocateMoreVotesThanBalanceReverts() public {
        vm.expectRevert("Insufficient Governance MANA");
        mana.allocateGovernanceVotes(addr1, 2000);
    }

    function testGovernanceVoteCasting() public {
        mana.allocateGovernanceVotes(addr1, 500);
        vm.prank(addr1);
        mana.voteForGovernance(1, 300);
        uint256 votes = mana.viewGovernanceVotes(1, addr1);
        assertEq(votes, 300);
    }

    function testVoteWithMoreVotesThanAllocatedReverts() public {
        mana.allocateGovernanceVotes(addr1, 500);
        vm.prank(addr1);
        vm.expectRevert("Not enough governance votes");
        mana.voteForGovernance(1, 600);
    }
}

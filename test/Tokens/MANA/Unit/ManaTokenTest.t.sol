// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";
import {MANA} from "src/Tokens/MANA.sol";

contract ManaTokenTest is Test {
    ManaToken manaToken;
    MANA manaGovernanceToken;
    address owner;
    address addr1;
    address addr2;

    bytes32 partition = keccak256("partition1");

    function setUp() public {
        owner = address(this); // Default test contract as owner
        addr1 = address(0x123);
        addr2 = address(0x456);

        // Deploy MANA Governance Token (ERC-1400)
        address;
        defaultOperators[0] = owner;

        bytes32;
        defaultPartitions[0] = partition;

        manaGovernanceToken = new MANA(defaultOperators, defaultPartitions);

        // Deploy ManaToken (ERC-20) with 10,000 initial supply
        manaToken = new ManaToken(10000, address(manaGovernanceToken));

        // Mint initial tokens to owner
        manaToken.mint(owner, 5000);
    }

    function testMintTokensToOwner() public {
        assertEq(manaToken.balanceOf(owner), 5000);
    }

    function testTokenTransfer() public {
        manaToken.transfer(addr1, 1000);
        assertEq(manaToken.balanceOf(addr1), 1000);
    }

    function testOwnerCanBurnTokens() public {
        manaToken.burn(500);
        assertEq(manaToken.balanceOf(owner), 4500);
    }

    function testNonOwnerCannotBurnTokens() public {
        vm.prank(addr1);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        manaToken.burn(500);
    }

    function testContributeManaAndConvertToMANA() public {
        manaToken.transfer(addr1, 1000);
        vm.prank(addr1);
        manaToken.contributeToCooperative(500);

        // Check MANA balance in governance token
        assertEq(
            manaGovernanceToken.balanceOfByPartition(addr1, partition),
            500
        );
    }

    function testContributionExceedsBalanceReverts() public {
        vm.prank(addr1);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        manaToken.contributeToCooperative(2000);
    }

    function testAllocateGovernanceVotes() public {
        manaToken.transfer(addr1, 1000);
        manaToken.contributeToCooperative(500);

        manaGovernanceToken.allocateGovernanceVotes(addr1, 300);
        assertEq(manaGovernanceToken.governanceVotes(addr1), 300);
    }

    function testNonOwnerCannotAllocateGovernanceVotes() public {
        vm.prank(addr1);
        vm.expectRevert("Ownable: caller is not the owner");
        manaGovernanceToken.allocateGovernanceVotes(addr1, 300);
    }

    function testVoteForGovernance() public {
        manaToken.transfer(addr1, 1000);
        manaToken.contributeToCooperative(500);

        manaGovernanceToken.allocateGovernanceVotes(addr1, 300);
        vm.prank(addr1);
        manaGovernanceToken.voteForGovernance(1, 200);

        assertEq(manaGovernanceToken.viewGovernanceVotes(1, addr1), 200);
    }

    function testVoteExceedsAllocatedVotesReverts() public {
        manaToken.transfer(addr1, 1000);
        manaToken.contributeToCooperative(500);

        manaGovernanceToken.allocateGovernanceVotes(addr1, 300);
        vm.prank(addr1);
        vm.expectRevert("Not enough governance votes");
        manaGovernanceToken.voteForGovernance(1, 400);
    }
}

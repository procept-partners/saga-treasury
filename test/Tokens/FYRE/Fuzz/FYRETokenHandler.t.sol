// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "lib/forge-std/src/Test.sol";
import {FyreToken} from "src/Tokens/FYREToken.sol";

contract FyreTokenHandler is Test {
    FyreToken fyreToken;
    address owner;

    uint256 constant MAX_SUPPLY = 1_000_000 ether; // Limit max token supply for fuzzing
    uint256 constant MIN_AMOUNT = 1 ether; // Min amount for minting/burning to avoid small numbers
    uint256 constant MAX_AMOUNT = 1_000 ether; // Max amount to mint/burn per operation

    constructor(FyreToken _fyreToken, address _owner) {
        fyreToken = _fyreToken;
        owner = _owner;
    }

    function mintTokens(address account, uint256 amount) public {
        // Check total supply before minting to avoid exceeding MAX_SUPPLY
        uint256 totalSupply = fyreToken.totalSupply();
        uint256 remainingSupply = MAX_SUPPLY - totalSupply;
        amount = bound(amount, MIN_AMOUNT, remainingSupply); // Bound the amount for safe fuzzing

        if (amount == 0) {
            return; // Prevent minting if no remaining supply
        }

        vm.prank(owner);
        fyreToken.mint(account, amount);
    }

    function burnTokens(address account, uint256 amount) public {
        uint256 balance = fyreToken.balanceOf(account);
        amount = bound(amount, MIN_AMOUNT, balance); // Bound to available balance to avoid underflow

        if (amount == 0) {
            return; // Prevent burning if balance is too small
        }

        vm.prank(owner);
        fyreToken.burn(account, amount);
    }

    function transferTokens(address from, address to, uint256 amount) public {
        uint256 balance = fyreToken.balanceOf(from);
        amount = bound(amount, MIN_AMOUNT, balance); // Avoid transferring more than the balance
        vm.prank(from);
        fyreToken.transfer(to, amount);
    }
}

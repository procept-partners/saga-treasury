// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {StdInvariant} from "lib/forge-std/src/StdInvariant.sol";
import {FyreTokenHandler} from "test/Tokens/FYRE/Fuzz/FYRETokenHandler.t.sol";
import {FyreToken} from "src/Tokens/FYREToken.sol";

contract FyreTokenInvariantTest is StdInvariant {
    FyreToken fyreToken;
    FyreTokenHandler handler;

    uint256 constant MAX_SUPPLY = 1_000_000 ether; // Maximum supply allowed

    function setUp() public {
        address owner = address(0xABCD);
        fyreToken = new FyreToken(owner, MAX_SUPPLY);
        handler = new FyreTokenHandler(fyreToken, owner);
        targetContract(address(handler)); // Set the handler as the target for fuzz testing
    }

    // Ensure that the total supply never exceeds the MAX_SUPPLY
    function invariant_TotalSupplyShouldBeWithinBounds() public view {
        uint256 totalSupply = fyreToken.totalSupply();
        assert(totalSupply <= MAX_SUPPLY); // Total supply should not exceed MAX_SUPPLY
        console.log("Total Supply: ", totalSupply);
    }
}

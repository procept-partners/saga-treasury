// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "lib/forge-std/src/Test.sol";
import {DeployFyreToken} from "script/Tokens/FYRE/DeployFYREToken.s.sol"; // Import the script
import {FyreToken} from "src/Tokens/FYREToken.sol";

contract DeployFyreTokenTest is Test {
    function testDeploymentScript() public {
        DeployFyreToken deployScript = new DeployFyreToken(); // Instantiate the script
        deployScript.run(); // Execute the script

        // Retrieve the deployed contract address from the DeployFyreToken script
        FyreToken fyreToken = FyreToken(address(deployScript.fyreToken())); // Access the public state variable

        // Test the deployed contract properties
        uint256 expectedSupply = 250_000 ether;
        assertEq(fyreToken.totalSupply(), expectedSupply);
        assertEq(fyreToken.balanceOf(fyreToken.owner()), expectedSupply);

        // Ensure the ownership was transferred to the final owner
        address finalOwner = 0x21310a7f2c88194fb70194df679b260F024cCF77;
        assertEq(fyreToken.owner(), finalOwner); // Ensure the owner is now the finalOwner
    }
}

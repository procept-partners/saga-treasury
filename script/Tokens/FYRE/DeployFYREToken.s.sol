// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {FyreToken} from "src/Tokens/FYREToken.sol";
import {console} from "lib/forge-std/src/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol"; // Import HelperConfig

contract DeployFyreToken is Script {
    // Declare fyreToken as a public state variable
    FyreToken public fyreToken;

    function run() external {
        // Use HelperConfig to determine the correct owner address
        HelperConfig helperConfig = new HelperConfig();
        address deployer = helperConfig.owner(); // Deployer address for initial minting
        address finalOwner = 0x21310a7f2c88194fb70194df679b260F024cCF77; // New owner address for production

        uint256 initialSupply = 250_000 ether; // Updated initial supply for hackathon

        // Start a broadcast as the deployer
        vm.startBroadcast(deployer);
        fyreToken = new FyreToken(deployer, initialSupply); // Deploy the contract

        // Transfer ownership to the final owner
        fyreToken.transferOwnership(finalOwner);

        // Transfer all minted tokens to the final owner
        fyreToken.transfer(finalOwner, initialSupply);
        vm.stopBroadcast();

        // Print the deployed contract address and the new owner address
        console.log("Deployed FyreToken at:", address(fyreToken));
        console.log("Ownership transferred to:", finalOwner);
    }
}

// File: script/DeployManaToken.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol"; // Adjust the import path as needed
import {console2} from "lib/forge-std/src/console2.sol";

contract DeployManaToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy ManaToken with initial supply of 1000 tokens and the specified address
        ManaToken manaToken = new ManaToken(
            1000,
            0x77e0dFD1D2BfEC5c1816F9c06BEe673b14e0f72e
        );

        console2.log("ManaToken deployed to:", address(manaToken));
        vm.stopBroadcast();
    }
}

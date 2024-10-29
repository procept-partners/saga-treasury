// File: script/DeployMANA.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {console} from "lib/forge-std/src/console.sol";

contract DeployMANA is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig
            .activeNetworkConfig;

        // Load the deployer's private key from the HelperConfig
        uint256 deployerPrivateKey = config.deployerKey;

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Retrieve the deployed MANA contracts
        MANA manaGovernanceToken = MANA(config.manaGovernanceToken);
        ManaToken manaToken = ManaToken(config.manaToken);

        // Log deployed contract addresses
        console.log(
            "MANA Governance Token deployed at:",
            address(manaGovernanceToken)
        );
        console.log("ManaToken deployed at:", address(manaToken));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

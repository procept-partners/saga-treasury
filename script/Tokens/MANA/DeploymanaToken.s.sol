// File: script/DeployManaToken.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {console2} from "lib/forge-std/src/console2.sol";

contract DeployManaToken is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();

        // Access the active configuration details directly
        HelperConfig.NetworkConfig memory config = helperConfig
            .getActiveNetworkConfig();
        // Ensure that the MANA governance token address is set
        require(
            config.manaGovernanceToken != address(0),
            "MANA Governance Token address not set"
        );

        vm.startBroadcast(config.deployerKey);

        // Deploy ManaToken with the MANA governance token's address
        ManaToken manaToken = new ManaToken(
            1000 * 10 ** 18, // Initial supply
            config.manaGovernanceToken // Use the deployed manaGovernanceToken address from the config
        );

        console2.log("ManaToken deployed to:", address(manaToken));

        // Update HelperConfig with the deployed ManaToken contract address
        helperConfig.setDeployedAddresses(
            config.manaGovernanceToken,
            address(manaToken),
            config.deployerKey
        );

        vm.stopBroadcast();
    }
}

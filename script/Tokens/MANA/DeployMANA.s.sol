// File: script/DeployMANA.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {console} from "lib/forge-std/src/console.sol";

contract DeployMANA is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();

        uint256 chainId = block.chainid;
        uint256 deployerPrivateKey;

        if (chainId == 31337) {
            // Anvil local network
            deployerPrivateKey = vm.envUint("LOCAL_PRIVATE_KEY");
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY"); // For other networks
        }

        vm.startBroadcast(deployerPrivateKey);

        // Declare and initialize the default operators and partitions
        address[] memory defaultOperators = new address[](1);
        defaultOperators[0] = msg.sender;

        bytes32[] memory defaultPartitions = new bytes32[](1);
        defaultPartitions[0] = keccak256(abi.encodePacked("PARTITION_A"));

        // Deploy the MANA contract with default operators and partitions
        MANA manaGovernanceToken = new MANA(
            defaultOperators,
            defaultPartitions
        );
        console.log(
            "MANA Governance Token deployed at:",
            address(manaGovernanceToken)
        );

        // Update HelperConfig with the deployed MANA contract address
        helperConfig.setDeployedAddresses(
            address(manaGovernanceToken),
            address(0), // Placeholder for ManaToken, which will be deployed later
            deployerPrivateKey
        );

        vm.stopBroadcast();
    }
}

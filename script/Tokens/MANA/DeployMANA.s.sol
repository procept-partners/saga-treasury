// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {console} from "forge-std/console.sol";

contract DeployMANA is Script {
    MANA public mana;

    function run() external {
        HelperConfig helperConfig = new HelperConfig();

        // Get the treasury address from HelperConfig; it may be address(0)
        address treasury = helperConfig.activeNetworkConfig.treasuryAddress;

        // Log a warning if treasury is set to the zero address
        if (treasury == address(0)) {
            console.log(
                "Warning: Treasury address is currently set to the zero address."
            );
        }

        bytes32[] memory defaultPartitions = new bytes32[](1);
        bytes32;
        defaultPartitions[0] = bytes32(0);

        // Retrieve deployer key
        uint256 deployerPrivateKey = helperConfig.getDeployerKey();

        // Begin broadcasting transaction
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the MANA contract with treasury and default partitions
        mana = new MANA(treasury, defaultPartitions);

        // Update HelperConfig with the deployed MANA contract address
        helperConfig.setDeployedMANAAddress(address(mana));

        // End broadcasting transaction
        vm.stopBroadcast();

        console.log("Deployed MANA at:", address(mana));
    }
}

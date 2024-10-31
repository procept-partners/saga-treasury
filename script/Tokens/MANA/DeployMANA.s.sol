// File: script/MANA/DeployMANA.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {HelperConfigMANA} from "./HelperConfigMANA.s.sol";
import {console} from "lib/forge-std/src/console.sol";

contract DeployMANA is Script {
    MANA public manaGovernanceToken;

    function run() external {
        HelperConfigMANA helperConfig = new HelperConfigMANA();
        uint256 deployerPrivateKey = helperConfig
            .activeNetworkConfig
            .deployerKey;

        vm.startBroadcast(deployerPrivateKey);
        manaGovernanceToken = new MANA(
            deployerPrivateKey,
            helperConfig.defaultPartitions()
        ); // Deployer as temp owner
        console.log(
            "MANA Governance Token deployed at:",
            address(manaGovernanceToken)
        );
        helperConfig.setDeployedAddresses(
            address(manaGovernanceToken),
            address(0),
            deployerPrivateKey
        );
        vm.stopBroadcast();
    }
}

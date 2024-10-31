// File: script/DeployMANA.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployMANA is Script {
    MANA public manaToken;

    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        uint256 deployerKey = helperConfig.activeNetworkConfig.deployerKey;

        vm.startBroadcast(deployerKey);
        manaToken = new MANA();
        helperConfig.setDeployedAddresses(
            address(0),
            address(manaToken),
            address(0),
            deployerKey
        );
        vm.stopBroadcast();

        console.log("Deployed MANA token at:", address(manaToken));
    }
}

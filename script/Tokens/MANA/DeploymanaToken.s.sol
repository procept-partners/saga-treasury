// File: script/DeployManaToken.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployManaToken is Script {
    ManaToken public manaToken;

    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        uint256 deployerKey = helperConfig.activeNetworkConfig.deployerKey;

        vm.startBroadcast(deployerKey);
        manaToken = new ManaToken(
            1000 * 10 ** 18,
            helperConfig.activeNetworkConfig.manaTokenAddress
        );
        helperConfig.setDeployedAddresses(
            helperConfig.activeNetworkConfig.fyreTokenAddress,
            address(manaToken),
            address(0),
            deployerKey
        );
        vm.stopBroadcast();

        console.log("ManaToken deployed to:", address(manaToken));
    }
}

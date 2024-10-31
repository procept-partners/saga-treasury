// File: script/Treasury/DeployTreasury.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Treasury} from "src/Treasury/Treasury.sol";
import {HelperConfigTreasury} from "./HelperConfigTreasury.s.sol";
import {FYREToken} from "src/Tokens/FYREToken.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";

contract DeployTreasury is Script {
    Treasury public treasury;

    function run() external {
        HelperConfigTreasury helperConfig = new HelperConfigTreasury();
        HelperConfigTreasury.NetworkConfig memory config = helperConfig
            .activeNetworkConfig;

        vm.startBroadcast(config.deployerKey);

        // Deploy Treasury with token addresses and configuration parameters
        treasury = new Treasury(
            config.fyreTokenAddress,
            config.manaTokenAddress,
            address(0), // Placeholder for USDC address
            address(0), // Placeholder for WBTC address
            address(this), // Authorized signer
            100, // usdcToFyreRate
            1000, // ethToFyreRate
            10, // wbtcToFyreRate
            5, // fyreToManaRate
            2 // fyreToShldRate
        );

        vm.stopBroadcast();
    }
}

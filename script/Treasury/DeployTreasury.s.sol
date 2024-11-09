// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Treasury} from "src/Treasury/Treasury.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployTreasury is Script {
    Treasury public treasury;

    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        uint256 deployerKey = helperConfig.activeNetworkConfig.deployerKey;

        address fyreTokenAddress = helperConfig
            .activeNetworkConfig
            .fyreTokenAddress;
        address manaTokenAddress = helperConfig
            .activeNetworkConfig
            .manaTokenAddress;

        vm.startBroadcast(deployerKey);

        treasury = new Treasury(
            fyreTokenAddress,
            manaTokenAddress,
            address(0), // USDC placeholder
            address(0), // WBTC placeholder
            address(this), // Authorized signer
            100, // usdcToFyreRate
            1000, // ethToFyreRate
            10, // wbtcToFyreRate
            5, // fyreToManaRate
            2 // fyreToShldRate
        );
        helperConfig.setDeployedTreasuryAddress(address(treasury));

        vm.stopBroadcast();
        console.log("Treasury deployed at:", address(treasury));
    }
}

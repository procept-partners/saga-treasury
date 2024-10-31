// File: script/Treasury/TransferOwnershipToTreasury.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FYREToken} from "src/Tokens/FYREToken.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";
import {HelperConfigTreasury} from "./HelperConfigTreasury.s.sol";

contract TransferOwnershipToTreasury is Script {
    function run() external {
        HelperConfigTreasury helperConfig = new HelperConfigTreasury();
        HelperConfigTreasury.NetworkConfig memory config = helperConfig
            .activeNetworkConfig;

        vm.startBroadcast(config.deployerKey);

        FyreToken(config.fyreTokenAddress).transferOwnership(address(treasury));
        MANA(config.manaTokenAddress).transferOwnership(address(treasury));
        ManaToken(config.manaTokenAddress).transferOwnership(address(treasury));

        vm.stopBroadcast();
    }
}

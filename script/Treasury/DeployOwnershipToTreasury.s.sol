// File: script/TransferOwnershipToTreasury.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FYREToken} from "src/Tokens/FYREToken.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract TransferOwnershipToTreasury is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        uint256 deployerKey = helperConfig.activeNetworkConfig.deployerKey;
        address treasuryAddress = helperConfig
            .activeNetworkConfig
            .treasuryAddress;

        vm.startBroadcast(deployerKey);
        FYREToken(helperConfig.activeNetworkConfig.fyreTokenAddress)
            .transferOwnership(treasuryAddress);
        MANA(helperConfig.activeNetworkConfig.manaTokenAddress)
            .transferOwnership(treasuryAddress);
        ManaToken(helperConfig.activeNetworkConfig.manaTokenAddress)
            .transferOwnership(treasuryAddress);
        vm.stopBroadcast();

        console.log(
            "Ownership of all tokens transferred to Treasury at:",
            treasuryAddress
        );
    }
}

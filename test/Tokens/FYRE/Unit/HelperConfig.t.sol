// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "lib/forge-std/src/Test.sol";
import {HelperConfig} from "script/Tokens/FYRE/HelperConfig.s.sol";

contract HelperConfigTest is Test {
    function testOwnerForLocalAnvilNetwork() public {
        vm.chainId(31337); // Simulate local Anvil network
        HelperConfig config = new HelperConfig();
        assertEq(config.owner(), 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // Default Anvil owner
    }

    function testOwnerForAuroraTestnet() public {
        vm.chainId(1313161555); // Simulate Aurora Testnet
        vm.envString(
            "OWNER_ADDRESS",
            "0x944Cd97fCFa1ABCf974455521B787757A7463fdC"
        );
        HelperConfig config = new HelperConfig();
        assertEq(config.owner(), 0x944Cd97fCFa1ABCf974455521B787757A7463fdC); // Expected Aurora testnet owner
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";

contract HelperConfig is Script {
    address public owner;

    constructor() {
        // Set the owner address depending on the network
        uint256 chainId = block.chainid;
        if (chainId == 31337) {
            // Local network (anvil)
            owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Anvil's default account
        } else if (chainId == 1313161555) {
            // Aurora testnet
            owner = vm.envAddress("OWNER_ADDRESS"); // From environment variable
        } else if (chainId == 1313161554) {
            // Aurora Mainnet
            owner = vm.envAddress("OWNER_ADDRESS");
        } else {
            // Default to the environment variable for other networks
            owner = vm.envAddress("OWNER_ADDRESS");
        }
    }
}

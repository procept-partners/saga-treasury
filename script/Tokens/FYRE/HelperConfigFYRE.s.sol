// File: script/FYRE/HelperConfigFYRE.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";

contract HelperConfigFYRE is Script {
    address public owner;

    constructor() {
        uint256 chainId = block.chainid;
        if (chainId == 31337) {
            owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Anvil's default account for local testing
        } else if (chainId == 1313161555) {
            owner = vm.envAddress("TREASURY_ADDRESS"); // Treasury address for Aurora testnet
        } else if (chainId == 1313161554) {
            owner = vm.envAddress("TREASURY_ADDRESS"); // Treasury address for Aurora mainnet
        } else {
            owner = vm.envAddress("TREASURY_ADDRESS");
        }
    }
}

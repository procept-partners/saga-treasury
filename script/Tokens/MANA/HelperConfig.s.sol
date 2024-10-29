// File: script/HelperConfig.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint256 public constant INITIAL_SUPPLY = 10000 * 10 ** 18;
    uint256 public constant DEFAULT_ANVIL_PRIVATE_KEY =
        0x59c6995e998f97a5a004497d4a9c9f90000000000000000000000000000000000; // Anvil Default Private Key

    struct NetworkConfig {
        address manaGovernanceToken;
        address manaToken;
        uint256 deployerKey;
    }

    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia Network
            activeNetworkConfig = getSepoliaConfig();
        } else {
            // Default to Anvil Config
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig()
        public
        view
        returns (NetworkConfig memory sepoliaConfig)
    {
        sepoliaConfig = NetworkConfig({
            manaGovernanceToken: 0x1234, // Sepolia MANA (ERC-1400) Address
            manaToken: 0x5678, // Sepolia ManaToken (ERC-20) Address
            deployerKey: vm.envUint("PRIVATE_KEY") // Set PRIVATE_KEY in .env for Sepolia
        });
    }

    function getOrCreateAnvilConfig()
        public
        returns (NetworkConfig memory anvilConfig)
    {
        if (activeNetworkConfig.manaGovernanceToken != address(0)) {
            return activeNetworkConfig;
        }

        // Broadcast transactions for mock contract deployment
        vm.startBroadcast();

        // Corrected contract instantiation
        MANA manaGovernanceToken = new MANA(); // Initialize MANA contract (assuming MANA constructor does not require parameters)
        ManaToken manaToken = new ManaToken(
            INITIAL_SUPPLY,
            address(manaGovernanceToken)
        ); // Mock ERC-20

        vm.stopBroadcast();

        anvilConfig = NetworkConfig({
            manaGovernanceToken: address(manaGovernanceToken),
            manaToken: address(manaToken),
            deployerKey: DEFAULT_ANVIL_PRIVATE_KEY
        });
    }
}

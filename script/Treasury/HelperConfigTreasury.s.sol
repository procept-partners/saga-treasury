// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

contract HelperConfigTreasury is Script {
    struct NetworkConfig {
        address fyreTokenAddress;
        address manaTokenAddress;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        uint256 chainId = block.chainid;
        activeNetworkConfig = getTreasuryNetworkConfig(chainId);
    }

    function getTreasuryNetworkConfig(
        uint256 chainId
    ) internal view returns (NetworkConfig memory config) {
        if (chainId == 31337) {
            // Anvil Local Network
            config = NetworkConfig({
                fyreTokenAddress: vm.envAddress("ANVIL_FYRE_TOKEN_ADDRESS"),
                manaTokenAddress: vm.envAddress("ANVIL_MANA_TOKEN_ADDRESS"),
                deployerKey: vm.envUint("ANVIL_DEPLOYER_KEY")
            });
        } else if (chainId == 1313161555) {
            // Aurora Testnet
            config = NetworkConfig({
                fyreTokenAddress: vm.envAddress(
                    "AURORA_TESTNET_FYRE_TOKEN_ADDRESS"
                ),
                manaTokenAddress: vm.envAddress(
                    "AURORA_TESTNET_MANA_TOKEN_ADDRESS"
                ),
                deployerKey: vm.envUint("AURORA_TESTNET_DEPLOYER_KEY")
            });
        } else if (chainId == 1313161554) {
            // Aurora Mainnet
            config = NetworkConfig({
                fyreTokenAddress: vm.envAddress(
                    "AURORA_MAINNET_FYRE_TOKEN_ADDRESS"
                ),
                manaTokenAddress: vm.envAddress(
                    "AURORA_MAINNET_MANA_TOKEN_ADDRESS"
                ),
                deployerKey: vm.envUint("AURORA_MAINNET_DEPLOYER_KEY")
            });
        } else {
            revert("Unsupported network");
        }
    }
}

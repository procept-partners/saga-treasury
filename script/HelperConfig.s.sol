// File: script/HelperConfig.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address fyreTokenAddress;
        address manaTokenAddress;
        uint256 deployerKey;
        address treasuryAddress;
    }

    NetworkConfig public activeNetworkConfig;
    address public owner;

    constructor() {
        uint256 chainId = block.chainid;
        activeNetworkConfig = getNetworkConfig(chainId);

        if (chainId == 31337) {
            owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        } else {
            owner = vm.envAddress("TREASURY_ADDRESS");
        }
    }

    function getNetworkConfig(
        uint256 chainId
    ) public view returns (NetworkConfig memory config) {
        if (chainId == 31337) {
            // Anvil Local Network
            config = NetworkConfig({
                fyreTokenAddress: vm.envAddress("ANVIL_FYRE_TOKEN_ADDRESS"),
                manaTokenAddress: vm.envAddress("ANVIL_MANA_TOKEN_ADDRESS"),
                deployerKey: vm.envUint("ANVIL_DEPLOYER_KEY"),
                treasuryAddress: vm.envAddress("ANVIL_TREASURY_ADDRESS")
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
                deployerKey: vm.envUint("AURORA_TESTNET_DEPLOYER_KEY"),
                treasuryAddress: vm.envAddress(
                    "AURORA_TESTNET_TREASURY_ADDRESS"
                )
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
                deployerKey: vm.envUint("AURORA_MAINNET_DEPLOYER_KEY"),
                treasuryAddress: vm.envAddress(
                    "AURORA_MAINNET_TREASURY_ADDRESS"
                )
            });
        } else {
            revert("Unsupported network");
        }
    }

    function setDeployedAddresses(
        address _fyreTokenAddress,
        address _manaTokenAddress,
        address _treasuryAddress,
        uint256 _deployerKey
    ) external {
        activeNetworkConfig = NetworkConfig({
            fyreTokenAddress: _fyreTokenAddress,
            manaTokenAddress: _manaTokenAddress,
            deployerKey: _deployerKey,
            treasuryAddress: _treasuryAddress
        });
    }
}

// File: script/MANA/HelperConfigMANA.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";

contract HelperConfigMANA is Script {
    NetworkConfig public activeNetworkConfig;
    address public owner;
    address[] public defaultOperators;
    bytes32[] public defaultPartitions;

    uint256 public constant INITIAL_SUPPLY = 10000 * 10 ** 18;
    uint256 public constant DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    struct NetworkConfig {
        address manaGovernanceToken;
        address manaToken;
        uint256 deployerKey;
    }

    constructor() {
        uint256 chainId = block.chainid;
        if (chainId == 31337) {
            owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
            activeNetworkConfig = getOrCreateAnvilConfig();
        } else {
            owner = vm.envAddress("TREASURY_ADDRESS"); // Treasury address for all other networks
            if (chainId == 1313161555) {
                activeNetworkConfig = getAuroraTestnetConfig();
            } else if (chainId == 1313161554) {
                activeNetworkConfig = getAuroraMainnetConfig();
            } else {
                activeNetworkConfig = getDefaultNetworkConfig();
            }
        }
    }

    function setDeployedAddresses(
        address _manaGovernanceToken,
        address _manaToken,
        uint256 _deployerKey
    ) external {
        activeNetworkConfig = NetworkConfig({
            manaGovernanceToken: _manaGovernanceToken,
            manaToken: _manaToken,
            deployerKey: _deployerKey
        });
    }

    function getOrCreateAnvilConfig()
        public
        returns (NetworkConfig memory anvilConfig)
    {
        if (activeNetworkConfig.manaGovernanceToken != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();

        MANA manaGovernanceToken = new MANA(
            defaultOperators,
            defaultPartitions
        );
        ManaToken manaToken = new ManaToken(
            INITIAL_SUPPLY,
            address(manaGovernanceToken)
        );

        vm.stopBroadcast();

        anvilConfig = NetworkConfig({
            manaGovernanceToken: address(manaGovernanceToken),
            manaToken: address(manaToken),
            deployerKey: DEFAULT_ANVIL_PRIVATE_KEY
        });

        activeNetworkConfig = anvilConfig;
    }

    // Aurora Testnet and Mainnet configs, as before
}

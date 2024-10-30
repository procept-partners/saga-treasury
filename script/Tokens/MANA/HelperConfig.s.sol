// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    address public owner;
    address[] public defaultOperators;
    bytes32[] public defaultPartitions;

    uint256 public constant INITIAL_SUPPLY = 10000 * 10 ** 18;
    uint256 public constant DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; // Anvil Default Private Key

    struct NetworkConfig {
        address manaGovernanceToken;
        address manaToken;
        uint256 deployerKey;
    }

    constructor() {
        uint256 chainId = block.chainid;
        if (chainId == 31337) {
            // Local network (Anvil)
            owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Anvil's default account
            activeNetworkConfig = getOrCreateAnvilConfig();
        } else if (chainId == 1313161555) {
            // Aurora testnet
            owner = vm.envAddress("OWNER_ADDRESS");
            activeNetworkConfig = getAuroraTestnetConfig();
        } else if (chainId == 1313161554) {
            // Aurora Mainnet
            owner = vm.envAddress("OWNER_ADDRESS");
            activeNetworkConfig = getAuroraMainnetConfig();
        } else {
            // Default to the environment variable for other networks
            owner = vm.envAddress("OWNER_ADDRESS");
            activeNetworkConfig = getDefaultNetworkConfig();
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

        // Deploy contracts for the local Anvil environment
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

    function getAuroraTestnetConfig()
        public
        view
        returns (NetworkConfig memory auroraTestnetConfig)
    {
        auroraTestnetConfig = NetworkConfig({
            manaGovernanceToken: 0x0D8Fb64D13C2076687F73c0Be5B2745F36bf59C3,
            manaToken: tryEnvAddress("AURORA_TESTNET_MANA_TOKEN"),
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getAuroraMainnetConfig()
        public
        view
        returns (NetworkConfig memory auroraMainnetConfig)
    {
        auroraMainnetConfig = NetworkConfig({
            manaGovernanceToken: tryEnvAddress(
                "AURORA_MAINNET_MANA_GOVERNANCE_TOKEN"
            ),
            manaToken: tryEnvAddress("AURORA_MAINNET_MANA_TOKEN"),
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getDefaultNetworkConfig()
        internal
        view
        returns (NetworkConfig memory defaultConfig)
    {
        defaultConfig = NetworkConfig({
            manaGovernanceToken: address(0),
            manaToken: address(0),
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function tryEnvAddress(string memory key) internal view returns (address) {
        try vm.envAddress(key) returns (address result) {
            return result;
        } catch {
            return address(0);
        }
    }

    function getActiveNetworkConfig()
        external
        view
        returns (NetworkConfig memory)
    {
        return activeNetworkConfig;
    }
}

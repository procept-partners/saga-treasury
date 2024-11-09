// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address fyreTokenAddress;
        address manaAddress;
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
            // Anvil Local Network with fallback to address(0) for each token address
            config = NetworkConfig({
                fyreTokenAddress: tryGetEnvAddress("ANVIL_FYRE_TOKEN_ADDRESS"),
                manaAddress: tryGetEnvAddress("ANVIL_MANA_ADDRESS"),
                manaTokenAddress: tryGetEnvAddress("ANVIL_MANA_TOKEN_ADDRESS"),
                deployerKey: vm.envUint("ANVIL_DEPLOYER_KEY"),
                treasuryAddress: tryGetEnvAddress("ANVIL_TREASURY_ADDRESS")
            });
        } else if (chainId == 1313161555) {
            // Aurora Testnet
            config = NetworkConfig({
                fyreTokenAddress: tryGetEnvAddress(
                    "AURORA_TESTNET_FYRE_TOKEN_ADDRESS"
                ),
                manaAddress: tryGetEnvAddress("AURORA_TESTNET_MANA_ADDRESS"),
                manaTokenAddress: tryGetEnvAddress(
                    "AURORA_TESTNET_MANA_TOKEN_ADDRESS"
                ),
                deployerKey: vm.envUint("AURORA_TESTNET_DEPLOYER_KEY"),
                treasuryAddress: tryGetEnvAddress(
                    "AURORA_TESTNET_TREASURY_ADDRESS"
                )
            });
        } else if (chainId == 1313161554) {
            // Aurora Mainnet
            config = NetworkConfig({
                fyreTokenAddress: tryGetEnvAddress(
                    "AURORA_MAINNET_FYRE_TOKEN_ADDRESS"
                ),
                manaAddress: tryGetEnvAddress("AURORA_MAINNET_MANA_ADDRESS"),
                manaTokenAddress: tryGetEnvAddress(
                    "AURORA_MAINNET_MANA_TOKEN_ADDRESS"
                ),
                deployerKey: vm.envUint("AURORA_MAINNET_DEPLOYER_KEY"),
                treasuryAddress: tryGetEnvAddress(
                    "AURORA_MAINNET_TREASURY_ADDRESS"
                )
            });
        } else {
            revert("Unsupported network");
        }
    }

    // Helper to safely get environment variables or return address(0) if not set
    function tryGetEnvAddress(
        string memory envName
    ) internal view returns (address) {
        try vm.envAddress(envName) returns (address addr) {
            return addr;
        } catch {
            return address(0);
        }
    }

    function setDeployedFYRETokenAddress(address _fyreTokenAddress) external {
        activeNetworkConfig.fyreTokenAddress = _fyreTokenAddress;
    }

    function setDeployedMANAAddress(address _manaAddress) external {
        activeNetworkConfig.fyreTokenAddress = _manaAddress;
    }

    function setDeployedManaTokenAddress(address _manaTokenAddress) external {
        activeNetworkConfig.manaTokenAddress = _manaTokenAddress;
    }

    function setDeployedTreasuryAddress(address _treasuryAddress) external {
        activeNetworkConfig.treasuryAddress = _treasuryAddress;
    }

    function getDeployerKey() external view returns (uint256) {
        return activeNetworkConfig.deployerKey;
    }
}

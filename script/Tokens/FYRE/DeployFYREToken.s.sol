// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {FYREToken} from "src/Tokens/FYREToken.sol";
import {console} from "lib/forge-std/src/console.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {strings} from "lib/solidity-stringutils/strings.sol";

using strings for string;
using strings for strings.slice;

contract DeployFyreToken is Script {
    FYREToken public fyreToken;

    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        address deployerAddress = helperConfig.owner();
        uint256 initialSupply = 250_000 ether;

        uint256 chainId = block.chainid;
        uint256 deployerPrivateKey = helperConfig
            .getNetworkConfig(chainId)
            .deployerKey;

        vm.startBroadcast(deployerPrivateKey);

        fyreToken = new FYREToken(deployerAddress, initialSupply);
        helperConfig.setDeployedFYRETokenAddress(address(fyreToken));

        vm.stopBroadcast();
        console.log("Deployed FYREToken at:", address(fyreToken));

        // Write the deployed address to the .env file
        string memory envFilePath = ".env";
        string memory key = "ANVIL_FYRE_TOKEN_ADDRESS";
        string memory value = vm.toString(address(fyreToken));
        updateEnv(envFilePath, key, value);
    }

    function updateEnv(
        string memory envFilePath,
        string memory key,
        string memory value
    ) internal {
        // Read the existing .env file (if it exists)
        string memory content = "";
        try vm.readFile(envFilePath) returns (string memory fileContent) {
            content = fileContent;
        } catch {
            // File doesn't exist yet, start with an empty string
        }

        // Check if the key exists in the file and update or append the value
        string memory keyWithEqual = string.concat(key, "=");
        strings.slice memory contentSlice = content.toSlice();
        strings.slice memory keySlice = keyWithEqual.toSlice();
        if (contentSlice.contains(keySlice)) {
            // Replace the existing value
            strings.slice memory prefix = contentSlice.split(keySlice);
            strings.slice memory suffix = contentSlice.split("\n".toSlice());
            string memory newContent = string.concat(
                prefix.toString(),
                keyWithEqual,
                value,
                "\n",
                suffix.toString()
            );
            vm.writeFile(envFilePath, newContent);
        } else {
            // Append the new key-value pair
            string memory newContent = string.concat(
                content,
                "\n",
                keyWithEqual,
                value
            );
            vm.writeFile(envFilePath, newContent);
        }
    }
}

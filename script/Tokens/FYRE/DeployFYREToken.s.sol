// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FYREToken} from "src/Tokens/FYREToken.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

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
    }
}

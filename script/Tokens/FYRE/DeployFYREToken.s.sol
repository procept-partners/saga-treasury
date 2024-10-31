// File: script/FYRE/DeployFyreToken.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {FYREToken} from "src/Tokens/FYREToken.sol";
import {console} from "lib/forge-std/src/console.sol";
import {HelperConfigFYRE} from "./HelperConfigFYRE.s.sol";

contract DeployFyreToken is Script {
    FYREToken public fyreToken;

    function run() external {
        HelperConfigFYRE helperConfig = new HelperConfigFYRE();
        address deployer = helperConfig.owner();
        uint256 initialSupply = 250_000 ether;

        vm.startBroadcast(deployer);
        fyreToken = new FYREToken(deployer, initialSupply); // Deploy without treasury for now
        vm.stopBroadcast();

        console.log("Deployed FyreToken at:", address(fyreToken));
    }
}

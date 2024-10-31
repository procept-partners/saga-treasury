// File: script/MANA/DeployManaToken.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {ManaToken} from "src/Tokens/ManaToken.sol";
import {HelperConfigMANA} from "./HelperConfigMANA.s.sol";
import {console2} from "lib/forge-std/src/console2.sol";

contract DeployManaToken is Script {
    ManaToken public manaToken;

    function run() external {
        HelperConfigMANA helperConfig = new HelperConfigMANA();
        HelperConfigMANA.NetworkConfig memory config = helperConfig
            .activeNetworkConfig;

        vm.startBroadcast(config.deployerKey);
        manaToken = new ManaToken(1000 * 10 ** 18, config.manaGovernanceToken); // Link to MANA governance token
        console2.log("ManaToken deployed to:", address(manaToken));
        helperConfig.setDeployedAddresses(
            config.manaGovernanceToken,
            address(manaToken),
            config.deployerKey
        );
        vm.stopBroadcast();
    }
}

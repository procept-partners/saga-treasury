// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {ManaBalanceVerifier} from "src/Treasury/ManaBalanceVerifier.sol";
import {console2} from "lib/forge-std/src/console2.sol";

contract DeployManaBalanceVerifier is Script {
    ManaBalanceVerifier public manaBalanceVerifier;

    function run() external {
        address signer = msg.sender; // Replace with the actual signer address

        vm.startBroadcast();
        manaBalanceVerifier = new ManaBalanceVerifier(signer);
        vm.stopBroadcast();

        console.log(
            "ManaBalanceVerifier deployed at:",
            address(manaBalanceVerifier)
        );
    }
}

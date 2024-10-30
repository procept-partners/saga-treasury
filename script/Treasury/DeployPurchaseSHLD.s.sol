// deploy_PurchaseSHLDProxy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {PurchaseSHLDProxy} from "src/Treasury/PurchaseSHLDProxy.sol";
import {FYRE} from "src/Tokens/FYREToken.sol";

contract DeployPurchaseSHLDProxy is Script {
    PurchaseSHLDProxy public purchaseSHLDProxy;

    function run() external {
        // Replace with the actual deployed token address and other values
        FYREToken fyreToken = FYREToken(
            0x3db2F4e2F3eFa0e6Aa1DB543041a392b4401b554
        ); // FYRE token address
        uint256 exchangeRate = 20; // SHLD per FYRE exchange rate
        address treasury = 0x944Cd97fCFa1ABCf974455521B787757A7463fdC; //Wills Personal Wallet address at the moment to act as a holder;                // Treasury wallet address

        vm.startBroadcast();
        purchaseSHLDProxy = new PurchaseSHLDProxy(
            fyreToken,
            exchangeRate,
            treasury
        );
        vm.stopBroadcast();

        console.log(
            "PurchaseSHLDProxy deployed at:",
            address(purchaseSHLDProxy)
        );
    }
}

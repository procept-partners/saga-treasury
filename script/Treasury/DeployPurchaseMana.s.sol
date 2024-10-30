// deploy_PurchaseMANA.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {PurchaseMANA} from "src/Treasury/PurchaseMANA.sol";
import {FYREToken} from "src/Tokens/FYREToken.sol";
import {MANA} from "src/Tokens/MANA.sol";

contract DeployPurchaseMANA is Script {
    PurchaseMANA public purchaseMANA;

    function run() external {
        // Replace with the actual deployed token addresses
        FYREToken fyreToken = FYREToken(
            0x3db2F4e2F3eFa0e6Aa1DB543041a392b4401b554
        ); // FYRE token address
        MANA manaToken = MANA(0x3db2F4e2F3eFa0e6Aa1DB543041a392b4401b554); // MANA token address
        uint256 exchangeRate = 10; // MANA per FYRE exchange rate
        address treasury = 0x944Cd97fCFa1ABCf974455521B787757A7463fdC; //Wills Personal Wallet address at the moment to act as a holder
        vm.startBroadcast();
        purchaseMANA = new PurchaseMANA(
            fyreToken,
            manaToken,
            exchangeRate,
            treasury
        );
        vm.stopBroadcast();

        console.log("PurchaseMANA deployed at:", address(purchaseMANA));
    }
}

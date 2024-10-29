// deploy_PurchaseMANA.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../Treasury/PurchaseMANA.sol";
import "../Tokens/FYREToken.sol";
import "../Tokens/MANA.sol";

contract DeployPurchaseMANA is Script {
    PurchaseMANA public purchaseMANA;

    function run() external {
        // Replace with the actual deployed token addresses
        FYREToken fyreToken = FYREToken(0x3db2F4e2F3eFa0e6Aa1DB543041a392b4401b554); // FYRE token address
        MANA manaToken = MANA(0xMANATokenAddressHere);           // MANA token address
        uint256 exchangeRate = 10;                               // MANA per FYRE exchange rate
        address treasury = 0xTreasuryAddressHere;                // Treasury wallet address

        vm.startBroadcast();
        purchaseMANA = new PurchaseMANA(fyreToken, manaToken, exchangeRate, treasury);
        vm.stopBroadcast();

        console.log("PurchaseMANA deployed at:", address(purchaseMANA));
    }
}

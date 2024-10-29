// deploy_PurchaseSHLDProxy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../Treasury/PurchaseSHLDProxy.sol";
import "../Tokens/FYREToken.sol";

contract DeployPurchaseSHLDProxy is Script {
    PurchaseSHLDProxy public purchaseSHLDProxy;

    function run() external {
        // Replace with the actual deployed token address and other values
        FYREToken fyreToken = FYREToken(0xFYRETokenAddressHere); // FYRE token address
        uint256 exchangeRate = 20;                               // SHLD per FYRE exchange rate
        address treasury = 0xTreasuryAddressHere;                // Treasury wallet address

        vm.startBroadcast();
        purchaseSHLDProxy = new PurchaseSHLDProxy(fyreToken, exchangeRate, treasury);
        vm.stopBroadcast();

        console.log("PurchaseSHLDProxy deployed at:", address(purchaseSHLDProxy));
    }
}

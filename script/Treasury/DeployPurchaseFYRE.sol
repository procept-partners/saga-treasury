// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {PurchaseFYRE} from "src/Treasury/PurchaseFYRE.sol";
import {FYREToken} from "src/Tokens/FYREToken.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DeployPurchaseFYRE is Script {
    PurchaseFYRE public purchaseFYRE;

    function run() external {
        // Replace with deployed token addresses
        FyreToken fyreToken = FyreToken(0xFYRETokenAddressHere); // FYRE token address
        IERC20 usdcToken = IERC20(0xUSDCTokenAddressHere);       // USDC token address
        IERC20 tbtcToken = IERC20(0xTBTCAddressHere);            // tBTC token address

        uint256 usdcToFyreRate = 100; // Initial FYRE per USDC rate
        uint256 ethToFyreRate = 200;  // Initial FYRE per ETH rate
        uint256 tbtcToFyreRate = 150; // Initial FYRE per tBTC rate

        address treasury = 0xTreasuryAddressHere; // Replace with the actual treasury address

        vm.startBroadcast();
        purchaseFYRE = new PurchaseFYRE(
            fyreToken,
            usdcToken,
            tbtcToken,
            usdcToFyreRate,
            ethToFyreRate,
            tbtcToFyreRate,
            treasury
        );
        vm.stopBroadcast();

        console.log("PurchaseFYRE deployed at:", address(purchaseFYRE));
    }
}

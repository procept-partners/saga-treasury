// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {PurchaseFYRE} from "src/Treasury/PurchaseFYRE.sol";
import {FYREToken} from "src/Tokens/FYREToken.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DeployPurchaseFYRE is Script {
    PurchaseFYRE public purchaseFYRE;

    function run() external {
        // Replace with deployed token addresses
        FyreToken fyreToken = FyreToken(
            0x3db2F4e2F3eFa0e6Aa1DB543041a392b4401b554
        ); // FYRE token address
        IERC20 usdcToken = IERC20(0x368ebb46aca6b8d0787c96b2b20bd3cc3f2c45f7); // USDC token address
        IERC20 wbtcToken = IERC20(0xf4eb217ba2454613b15dbdea6e5f22276410e89e); // tBTC token address

        uint256 usdcToFyreRate = 100; // Initial FYRE per USDC rate
        uint256 ethToFyreRate = 200; // Initial FYRE per ETH rate
        uint256 wbtcToFyreRate = 150; // Initial FYRE per tBTC rate

        address treasury = 0x944Cd97fCFa1ABCf974455521B787757A7463fdC; //Wills Personal Wallet address at the moment to act as a holder
        vm.startBroadcast();

        vm.startBroadcast();
        purchaseFYRE = new PurchaseFYRE(
            fyreToken,
            usdcToken,
            wbtcToken,
            usdcToFyreRate,
            ethToFyreRate,
            wbtcToFyreRate,
            treasury
        );
        vm.stopBroadcast();

        console.log("PurchaseFYRE deployed at:", address(purchaseFYRE));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Oracle} from "src/Treasury/Oracle.sol";

contract DeployGenesisPriceOracle is Script {
    GenesisPriceOracle public genesisPriceOracle;

    function run() external {
        address fyre = 0x3db2F4e2F3eFa0e6Aa1DB543041a392b4401b554;          // Replace with actual FYRE address
        address manaERC20 = 0xMANAERC20AddressHere; // Replace with actual MANA ERC20 address
        address shld = 0x1;               // Replace with actual SHLD address
        uint256 fyrePrice = 100;           // Replace with actual price for FYRE
        uint256 manaERC20Price = 200;      // Replace with actual price for MANA ERC20
        uint256 shldPrice = 500;           // Replace with actual price for SHLD

        vm.startBroadcast();
        genesisPriceOracle = new GenesisPriceOracle(
            fyre,
            manaERC20,
            shld,
            fyrePrice,
            manaERC20Price,
            shldPrice
        );
        vm.stopBroadcast();

        console.log("GenesisPriceOracle deployed at:", address(genesisPriceOracle));
    }
}

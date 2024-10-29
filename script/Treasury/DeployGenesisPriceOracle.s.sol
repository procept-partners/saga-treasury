// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Oracle} from "src/Treasury/Oracle.sol";

contract DeployGenesisPriceOracle is Script {
    GenesisPriceOracle public genesisPriceOracle;

    function run() external {
        address fyre = 0xFYREAddressHere;          // Replace with actual FYRE address
        address manaERC20 = 0xMANAERC20AddressHere; // Replace with actual MANA ERC20 address
        address labContrib = 0xLABCONTRIBAddress;   // Replace with actual LAB_CONTRIB address
        address finContrib = 0xFINCONTRIBAddress;   // Replace with actual FIN_CONTRIB address
        address shld = 0xSHLDAddress;               // Replace with actual SHLD address

        uint256 fyrePrice = 100;           // Replace with actual price for FYRE
        uint256 manaERC20Price = 200;      // Replace with actual price for MANA ERC20
        uint256 labContribPrice = 300;     // Replace with actual price for LAB_CONTRIB
        uint256 finContribPrice = 400;     // Replace with actual price for FIN_CONTRIB
        uint256 shldPrice = 500;           // Replace with actual price for SHLD

        vm.startBroadcast();
        genesisPriceOracle = new GenesisPriceOracle(
            fyre,
            manaERC20,
            labContrib,
            finContrib,
            shld,
            fyrePrice,
            manaERC20Price,
            labContribPrice,
            finContribPrice,
            shldPrice
        );
        vm.stopBroadcast();

        console.log("GenesisPriceOracle deployed at:", address(genesisPriceOracle));
    }
}

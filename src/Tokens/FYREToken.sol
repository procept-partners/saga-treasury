// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract FyreToken is ERC20, Ownable {
    constructor(
        address owner,
        uint256 initialSupply
    ) ERC20("FyreToken", "FYRE") {
        _mint(owner, initialSupply);
        transferOwnership(owner);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}

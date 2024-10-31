// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract FYREToken is ERC20, Ownable {
    address public treasury;

    constructor(
        address owner,
        uint256 initialSupply
    ) ERC20("FyreToken", "FYRE") Ownable(owner) {
        _mint(owner, initialSupply);
        transferOwnership(owner);
    }

    modifier onlyTreasury() {
        require(msg.sender == treasury, "Only Treasury can call this function");
        _;
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(treasury == address(0), "Treasury already set");
        treasury = _treasury;
    }

    function mint(address account, uint256 amount) external onlyTreasury {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyTreasury {
        _burn(account, amount);
    }
}

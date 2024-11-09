// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ManaToken is ERC20, Ownable {
    constructor(
        address owner,
        uint256 initialSupply
    ) ERC20("mana ERC20", "mana") {
        _mint(owner, initialSupply); // Mint initial supply to the specified owner
        transferOwnership(owner); // Transfer ownership to the specified owner
    }

    /**
     * @dev Allows the owner to mint new tokens to a specified account.
     * @param account The address to which tokens will be minted.
     * @param amount The number of tokens to mint.
     */
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    /**
     * @dev Allows the owner to burn tokens from a specified account.
     * @param account The address from which tokens will be burned.
     * @param amount The number of tokens to burn.
     */
    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}

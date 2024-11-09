// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FYREToken is ERC20, Ownable {
    address public treasury;

    constructor(
        address owner,
        uint256 initialSupply
    ) ERC20("FyreToken", "FYRE") {
        _mint(owner, initialSupply);
        transferOwnership(owner);
    }

    modifier onlyTreasury() {
        require(msg.sender == treasury, "Only Treasury can call this function");
        _;
    }

    /**
     * @dev Sets the Treasury address. Can only be set once by the contract owner.
     */
    function setTreasury(address _treasury) external onlyOwner {
        require(treasury == address(0), "Treasury already set");
        treasury = _treasury;
    }

    /**
     * @dev Allows the Treasury to mint new tokens to a specified account.
     */
    function mint(address account, uint256 amount) external onlyTreasury {
        _mint(account, amount);
    }

    /**
     * @dev Allows the Treasury to burn tokens from a specified account.
     */
    function burn(address account, uint256 amount) external onlyTreasury {
        _burn(account, amount);
    }
}

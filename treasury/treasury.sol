// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../tokens/FYREToken.sol";
import "../tokens/MANA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../treasury/price_oracle.sol";

contract Treasury is Ownable {
    using ECDSA for bytes32;

    FYREToken public fyreToken;
    MANA public manaToken;
    IERC20 public usdcToken;
    IERC20 public wbtcToken;
    IPriceOracle public priceOracle;           // Oracle for price data
    address public authorizedSigner;
    address public collateralVerificationOracle; // Oracle to verify collateral (e.g., BTC backing)
    address public governanceApprovalOracle;   // Oracle for relaying governance approvals from NEAR

    uint256 public purchaseCounter;

    // Events for tracking
    event FYREPurchase(address indexed buyer, uint256 fyreAmount, string method);
    event MANAConversion(address indexed buyer, uint256 fyreAmount, uint256 manaAmount);
    event SHLDPurchaseRecorded(
        uint256 indexed purchaseId,
        address indexed buyer,
        uint256 fyreAmount,
        uint256 shldAmount,
        uint256 timestamp,
        bytes32 dataHash
    );
    event ProjectApprovalReceived(uint256 indexed projectId, uint256 approvedFYREQuantity, uint256 approvedManaQuantity);

    constructor(
        FYREToken _fyreToken,
        MANA _manaToken,
        IERC20 _usdcToken,
        IERC20 _wbtcToken,
        address _authorizedSigner,
        address _priceOracle,
        address _collateralVerificationOracle,
        address _governanceApprovalOracle
    ) Ownable() {
        fyreToken = _fyreToken;
        manaToken = _manaToken;
        usdcToken = _usdcToken;
        wbtcToken = _wbtcToken;
        authorizedSigner = _authorizedSigner;
        priceOracle = IPriceOracle(_priceOracle);
        collateralVerificationOracle = _collateralVerificationOracle;
        governanceApprovalOracle = _governanceApprovalOracle;

        fyreToken.setTreasury(address(this));
        manaToken.setTreasury(address(this));
    }

    /**
     * @dev Modifies the governance approval oracle address if necessary, only by owner.
     */
    function setGovernanceApprovalOracle(address _governanceApprovalOracle) external onlyOwner {
        governanceApprovalOracle = _governanceApprovalOracle;
    }

    /**
     * @dev Only allows the governance approval oracle to call certain functions.
     */
    modifier onlyGovernanceApprovalOracle() {
        require(msg.sender == governanceApprovalOracle, "Unauthorized source");
        _;
    }

    /**
     * @dev Process project approval relayed from NEAR’s governance contract, allowing for approved FYRE and MANA minting.
     * This function can only be called by the governance approval oracle.
     * @param projectId The ID of the approved project.
     * @param approvedFYREQuantity Quantity of FYRE to mint based on the project approval.
     * @param approvedManaQuantity Quantity of MANA to mint based on the project approval.
     */
    function processProjectApproval(uint256 projectId, uint256 approvedFYREQuantity, uint256 approvedManaQuantity) external onlyGovernanceApprovalOracle {
        if (approvedFYREQuantity > 0) {
            fyreToken.mint(address(this), approvedFYREQuantity);
            emit FYREPurchase(address(this), approvedFYREQuantity, "Governance Approved Mint");
        }

        if (approvedManaQuantity > 0) {
            manaToken.mint(address(this), approvedManaQuantity);
        }

        emit ProjectApprovalReceived(projectId, approvedFYREQuantity, approvedManaQuantity);
    }

    /**
     * @dev Converts ERC20 manaToken to ERC1400 MANA in "labor contribution" partition.
     */
    function convertManaToMANA(uint256 amount) external {
        require(manaToken.balanceOf(msg.sender) >= amount, "Insufficient ERC20 mana balance");
        manaToken.burn(msg.sender, amount);
        manaToken.mint(msg.sender, amount, keccak256("labor contribution"));
        emit MANAConversion(msg.sender, amount);
    }

    /**
     * @dev Purchase MANA in the financial partition using FYRE.
     */
    function purchaseMANAInFinancialPartition(uint256 fyreAmount) external {
        uint256 manaFinancialPrice = priceOracle.getPrice(address(manaToken), keccak256("financial contribution"));
        uint256 fyreToManaRate = priceOracle.getPrice(address(fyreToken), "");

        uint256 manaAmount = (fyreAmount * fyreToManaRate) / manaFinancialPrice;

        require(fyreToken.balanceOf(msg.sender) >= fyreAmount, "Insufficient FYRE balance");
        fyreToken.transferFrom(msg.sender, address(this), fyreAmount);
        manaToken.mint(msg.sender, manaAmount, keccak256("financial contribution"));
        emit MANAConversion(msg.sender, fyreAmount, manaAmount);
    }

    receive() external payable {}
}

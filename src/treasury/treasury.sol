// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../tokens/FYREToken.sol";
import "../tokens/MANA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../treasury/oracle.sol";

contract Treasury is Ownable {
    using ECDSA for bytes32;

    FYREToken public fyreToken;
    MANA public manaToken;
    IERC20 public usdcToken;
    IERC20 public wbtcToken;
    IPriceOracle public priceOracle;  // Retained for price data
    address public authorizedGovernanceSigner;
    address public authorizedCollateralSigner;

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
        address _priceOracle,
        address _authorizedGovernanceSigner,
        address _authorizedCollateralSigner
    ) Ownable() {
        fyreToken = _fyreToken;
        manaToken = _manaToken;
        usdcToken = _usdcToken;
        wbtcToken = _wbtcToken;
        priceOracle = IPriceOracle(_priceOracle);
        authorizedGovernanceSigner = _authorizedGovernanceSigner;
        authorizedCollateralSigner = _authorizedCollateralSigner;

        fyreToken.setTreasury(address(this));
        manaToken.setTreasury(address(this));
    }

    /**
     * @dev Sets new authorized signers, if needed, only by owner.
     */
    function setAuthorizedSigners(address _governanceSigner, address _collateralSigner) external onlyOwner {
        authorizedGovernanceSigner = _governanceSigner;
        authorizedCollateralSigner = _collateralSigner;
    }

    /**
     * @dev Process project approval using a signature from the authorized governance signer.
     * @param projectId The ID of the approved project.
     * @param approvedFYREQuantity Quantity of FYRE to mint.
     * @param approvedManaQuantity Quantity of MANA to mint.
     * @param signature Signed message verifying the approval from NEAR governance.
     */
    function processProjectApproval(
        uint256 projectId,
        uint256 approvedFYREQuantity,
        uint256 approvedManaQuantity,
        bytes memory signature
    ) external {
        bytes32 messageHash = keccak256(
            abi.encodePacked(projectId, approvedFYREQuantity, approvedManaQuantity)
        ).toEthSignedMessageHash();

        require(
            messageHash.recover(signature) == authorizedGovernanceSigner,
            "Invalid signature from governance"
        );

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
     * @dev Verifies collateral with a signature from the authorized collateral signer.
     * @param collateralAmount The amount of BTC collateral required.
     * @param signature Signed message verifying the collateral on Verus.
     */
    function verifyCollateral(uint256 collateralAmount, bytes memory signature) public view returns (bool) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(collateralAmount)
        ).toEthSignedMessageHash();

        return messageHash.recover(signature) == authorizedCollateralSigner;
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

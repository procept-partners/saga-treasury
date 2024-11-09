// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../tokens/FYREToken.sol";
import "../tokens/MANA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../treasury/oracle.sol"; // Adjusted for the project structure

contract Treasury is Ownable {
    using ECDSA for bytes32;

    FYREToken public fyreToken;
    MANA public manaToken;
    IERC20 public usdcToken;
    IERC20 public wbtcToken;
    IPriceOracle public priceOracle;
    address public authorizedSigner;

    uint256 public purchaseCounter;

    // Mappings for collateral and DAO-controlled limits
    mapping(address => uint256) public manaBalances;
    mapping(address => uint256) public collateralManaBalances;

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
    event OwnershipDataReceived(
        string chain, 
        string accountId, 
        bytes32 tokenHash, 
        uint256 timestamp
    );
    event BalanceProof(address indexed account, uint256 manaBalance, uint256 collateralManaBalance, bytes signature);

    constructor(
        FYREToken _fyreToken,
        MANA _manaToken,
        IERC20 _usdcToken,
        IERC20 _wbtcToken,
        address _authorizedSigner,
        address _priceOracle
    ) Ownable() {
        fyreToken = _fyreToken;
        manaToken = _manaToken;
        usdcToken = _usdcToken;
        wbtcToken = _wbtcToken;
        authorizedSigner = _authorizedSigner;
        priceOracle = IPriceOracle(_priceOracle);

        // Set Treasury contract as controller for FYREToken and MANA
        fyreToken.setTreasury(address(this));
        manaToken.setTreasury(address(this));
    }

    /**
     * @dev Calculates governance power for a given address based on aggregate mana and MANA holdings.
     * @param holder The address of the token holder whose governance power is being calculated.
     * @return Governance power as a percentage of the circulating supply.
     */
    function calculateGovernancePower(address holder) public view returns (uint256) {
        uint256 circulatingMana = manaToken.totalSupply();
        uint256 circulatingMANA = manaToken.totalSupply(); // Assumes total supply across partitions

        uint256 totalCirculatingSupply = circulatingMana + circulatingMANA;

        uint256 holderManaBalance = manaToken.balanceOf(holder);
        uint256 holderLaborMANA = manaToken.balanceOfByPartition(holder, manaToken.LABOR_CONTRIBUTION());
        uint256 holderFinancialMANA = manaToken.balanceOfByPartition(holder, manaToken.FINANCIAL_CONTRIBUTION());
        uint256 holderTotalMANA = holderLaborMANA + holderFinancialMANA;

        uint256 holderTotalBalance = holderManaBalance + holderTotalMANA;

        if (totalCirculatingSupply == 0) {
            return 0; // Avoid division by zero
        }
        
        uint256 governancePower = (holderTotalBalance * 1e18) / totalCirculatingSupply;

        return governancePower;
    }

    /**
     * @dev Purchase FYRE tokens using USDC, based on the latest price from the oracle.
     */
    function purchaseFYREWithUSDC(uint256 usdcAmount) external {
        uint256 fyreToUsdcRate = priceOracle.getPrice(address(fyreToken), "");
        uint256 fyreAmount = usdcAmount * fyreToUsdcRate;
        usdcToken.transferFrom(msg.sender, address(this), usdcAmount);
        fyreToken.mint(msg.sender, fyreAmount);
        emit FYREPurchase(msg.sender, fyreAmount, "USDC");
    }

    /**
     * @dev Purchase FYRE tokens using wBTC, based on the latest price from the oracle.
     */
    function purchaseFYREWithwBTC(uint256 wbtcAmount) external {
        uint256 fyreToWbtcRate = priceOracle.getPrice(address(fyreToken), "");
        uint256 fyreAmount = wbtcAmount * fyreToWbtcRate;
        wbtcToken.transferFrom(msg.sender, address(this), wbtcAmount);
        fyreToken.mint(msg.sender, fyreAmount);
        emit FYREPurchase(msg.sender, fyreAmount, "wBTC");
    }

    /**
     * @dev Purchase FYRE tokens using ETH, based on the latest price from the oracle.
     */
    function purchaseFYREWithETH() external payable {
        uint256 fyreToEthRate = priceOracle.getPrice(address(fyreToken), "");
        uint256 fyreAmount = msg.value * fyreToEthRate;
        fyreToken.mint(msg.sender, fyreAmount);
        emit FYREPurchase(msg.sender, fyreAmount, "ETH");
    }

    /**
     * @dev Converts ERC20 manaToken to ERC1400 MANA by burning ERC20 and minting ERC1400 in the "labor contribution" partition.
     * No collateralization is involved in this process; it is a simple burn-and-mint to the labor partition.
     */
    function convertManaToMANA(uint256 amount) external {
        require(manaToken.balanceOf(msg.sender) >= amount, "Insufficient ERC20 mana balance");

        // Burn the specified amount of mana (ERC-20)
        manaToken.burn(msg.sender, amount);

        // Mint the equivalent amount of MANA in the "labor contribution" partition
        manaToken.mint(msg.sender, amount, keccak256("labor contribution"));

        emit MANAConversion(msg.sender, amount);
    }

    /**
     * @dev Purchase SHLD tokens using FYRE with tracking.
     */
    function purchaseSHLD(uint256 fyreAmount) external {
        uint256 shldPrice = priceOracle.getPrice(address(fyreToken), "");
        uint256 shldAmount = fyreAmount * shldPrice;
        fyreToken.transferFrom(msg.sender, address(this), fyreAmount);

        purchaseCounter++;
        bytes32 dataHash = keccak256(abi.encodePacked(purchaseCounter, msg.sender, fyreAmount, shldAmount, block.timestamp));
        emit SHLDPurchaseRecorded(purchaseCounter, msg.sender, fyreAmount, shldAmount, block.timestamp, dataHash);
    }

    /**
     * @dev Ownership verification for multi-chain with ECDSA.
     */
    function receiveOwnershipProof(
        string memory chain, 
        string memory accountId, 
        bytes32 tokenHash, 
        bytes memory signature
    ) public returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(chain, accountId, " owns SHLD token ", tokenHash));
        address recoveredSigner = messageHash.toEthSignedMessageHash().recover(signature);
        require(recoveredSigner == authorizedSigner, "Invalid signature");
        emit OwnershipDataReceived(chain, accountId, tokenHash, block.timestamp);
        return true;
    }

    /**
     * @dev Set collateral balances and issue proofs.
     */
    function setBalances(address account, uint256 mana, uint256 collateral) external onlyOwner {
        manaBalances[account] = mana;
        collateralManaBalances[account] = collateral;
    }

    function generateProof(address account) external returns (bytes memory) {
        bytes32 messageHash = keccak256(abi.encodePacked(account, manaBalances[account], collateralManaBalances[account]));
        bytes memory signature = abi.encodePacked(messageHash);
        emit BalanceProof(account, manaBalances[account], collateralManaBalances[account], signature);
        return signature;
    }

    receive() external payable {}



    /**
     * @dev Purchase MANA in the financial partition using FYRE.
     * @param fyreAmount The amount of FYRE tokens provided by the buyer.
     */
    function purchaseMANAInFinancialPartition(uint256 fyreAmount) external {
        uint256 manaFinancialPrice = priceOracle.getPrice(address(manaToken), keccak256("financial contribution"));
        uint256 fyreToManaRate = priceOracle.getPrice(address(fyreToken), "");
        
        // Calculate the amount of MANA to mint based on FYRE provided and the current price
        uint256 manaAmount = (fyreAmount * fyreToManaRate) / manaFinancialPrice;

        // Ensure the user has enough FYRE
        require(fyreToken.balanceOf(msg.sender) >= fyreAmount, "Insufficient FYRE balance");

        // Transfer FYRE from the buyer to the treasury as collateral
        fyreToken.transferFrom(msg.sender, address(this), fyreAmount);

        // Mint MANA in the financial partition to the buyer
        manaToken.mint(msg.sender, manaAmount, keccak256("financial contribution"));

        emit MANAConversion(msg.sender, fyreAmount, manaAmount);
    }
}

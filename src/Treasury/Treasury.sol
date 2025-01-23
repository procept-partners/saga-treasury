// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FYREToken} from "src/Tokens/FYREToken.sol";
import {MANA} from "src/Tokens/MANA.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";


contract Treasury is Ownable {
    using ECDSA for bytes32;

    FYREToken public fyreToken;
    MANA public manaToken;
    IERC20 public usdcToken;
    IERC20 public wbtcToken;
    address public authorizedSigner;

    // Exchange rates
    uint256 public usdcToFyreRate;
    uint256 public ethToFyreRate;
    uint256 public wbtcToFyreRate;
    uint256 public fyreToManaRate;
    uint256 public fyreToShldRate;

    // Events
    event BalanceProof(
        address indexed account,
        uint256 manaBalance,
        uint256 collateralManaBalance,
        bytes signature
    );

    event OwnershipDataReceived(
        string nearAccountId,
        bytes32 tokenHash,
        uint256 timestamp
    );

    event SHLDPurchaseRecorded(
        uint256 indexed purchaseId,
        address indexed buyer,
        uint256 fyreAmount,
        uint256 shldAmount,
        uint256 timestamp,
        bytes32 dataHash
    );

    constructor(
        FYREToken _fyreToken,
        MANA _manaToken,
        IERC20 _usdcToken,
        IERC20 _wbtcToken,
        address _authorizedSigner,
        uint256 _usdcToFyreRate,
        uint256 _ethToFyreRate,
        uint256 _wbtcToFyreRate,
        uint256 _fyreToManaRate,
        uint256 _fyreToShldRate
    ) Ownable(msg.sender) {
        fyreToken = _fyreToken;
        manaToken = _manaToken;
        usdcToken = _usdcToken;
        wbtcToken = _wbtcToken;
        authorizedSigner = _authorizedSigner;

        usdcToFyreRate = _usdcToFyreRate;
        ethToFyreRate = _ethToFyreRate;
        wbtcToFyreRate = _wbtcToFyreRate;
        fyreToManaRate = _fyreToManaRate;
        fyreToShldRate = _fyreToShldRate;

        fyreToken.transferOwnership(address(this));
        manaToken.transferOwnership(address(this));
    }

    // Purchase FYRE tokens with USDC
    function purchaseFYREWithUSDC(uint256 usdcAmount) external {
        uint256 fyreAmount = usdcAmount * usdcToFyreRate;
        require(
            usdcToken.balanceOf(msg.sender) >= usdcAmount,
            "Insufficient USDC balance"
        );

        usdcToken.transferFrom(msg.sender, address(this), usdcAmount);
        fyreToken.mint(msg.sender, fyreAmount);
    }

    // Purchase FYRE tokens with wBTC
    function purchaseFYREWithwBTC(uint256 wbtcAmount) external {
        uint256 fyreAmount = wbtcAmount * wbtcToFyreRate;
        require(
            wbtcToken.balanceOf(msg.sender) >= wbtcAmount,
            "Insufficient wBTC balance"
        );

        wbtcToken.transferFrom(msg.sender, address(this), wbtcAmount);
        fyreToken.mint(msg.sender, fyreAmount);
    }

    // Purchase FYRE tokens with ETH
    function purchaseFYREWithETH() external payable {
        uint256 fyreAmount = msg.value * ethToFyreRate;
        require(msg.value > 0, "No ETH sent");

        fyreToken.mint(msg.sender, fyreAmount);
    }

    // Purchase MANA with FYRE
    function purchaseMANA(uint256 fyreAmount) external {
        uint256 manaAmount = fyreAmount * fyreToManaRate;
        require(
            fyreToken.balanceOf(msg.sender) >= fyreAmount,
            "Insufficient FYRE balance"
        );

        fyreToken.transferFrom(msg.sender, address(this), fyreAmount);
        manaToken.mint(
            msg.sender,
            manaAmount,
            keccak256("financial contribution")
        );
    }

    // Purchase SHLD with FYRE and log purchase for off-chain processing
    uint256 public purchaseCounter;

    function purchaseSHLD(uint256 fyreAmount) external {
        uint256 shldAmount = fyreAmount * fyreToShldRate;
        require(
            fyreToken.balanceOf(msg.sender) >= fyreAmount,
            "Insufficient FYRE balance"
        );

        fyreToken.transferFrom(msg.sender, address(this), fyreAmount);
        purchaseCounter++;

        bytes32 dataHash = keccak256(
            abi.encodePacked(
                purchaseCounter,
                msg.sender,
                fyreAmount,
                shldAmount,
                block.timestamp
            )
        );

        emit SHLDPurchaseRecorded(
            purchaseCounter,
            msg.sender,
            fyreAmount,
            shldAmount,
            block.timestamp,
            dataHash
        );
    }

    // Verify ownership proof for SHLD on NEAR
    function receiveOwnershipProof(
        string memory nearAccountId,
        bytes32 tokenHash,
        bytes memory signature
    ) public returns (bool) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(nearAccountId, " owns SHLD token ", tokenHash)
        );

        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);

        address recoveredSigner = ethSignedMessageHash.recover(signature);
        require(recoveredSigner == authorizedSigner, "Invalid signature");

        emit OwnershipDataReceived(nearAccountId, tokenHash, block.timestamp);
        return true;
    }

    // Set balance for Mana and collateral for NEAR proofing
    mapping(address => uint256) public manaBalances;
    mapping(address => uint256) public collateralManaBalances;

    function setBalances(
        address account,
        uint256 mana,
        uint256 collateral
    ) external onlyOwner {
        manaBalances[account] = mana;
        collateralManaBalances[account] = collateral;
    }

    function generateProof(address account) external returns (bytes memory) {
        uint256 mana = manaBalances[account];
        uint256 collateral = collateralManaBalances[account];

        bytes32 messageHash = keccak256(
            abi.encodePacked(account, mana, collateral)
        );
        bytes memory signature = abi.encodePacked(messageHash);

        emit BalanceProof(account, mana, collateral, signature);
        return signature;
    }

    // Update exchange rates
    function setExchangeRates(
        uint256 newUsdcRate,
        uint256 newEthRate,
        uint256 newWbtcRate,
        uint256 newManaRate,
        uint256 newShldRate
    ) external onlyOwner {
        usdcToFyreRate = newUsdcRate;
        ethToFyreRate = newEthRate;
        wbtcToFyreRate = newWbtcRate;
        fyreToManaRate = newManaRate;
        fyreToShldRate = newShldRate;
    }

    receive() external payable {} // Accept ETH deposits
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";

/**
 * @title CollateralManager
 * @notice Manages collateral (ETH and USDT) for loans with liquidation functionality
 * @dev Integrates with Chainlink price oracle for ETH/USD price feeds
 */
contract CollateralManager is ReentrancyGuard, Pausable, Ownable {
    // Collateral types
    enum CollateralType {
        ETH,
        USDT
    }

    // Collateral info for each loan
    struct Collateral {
        CollateralType collateralType;
        uint256 amount; // Amount in wei (ETH) or USDT smallest unit
        uint256 loanAmount; // USDT loan amount (6 decimals)
        uint256 lockedAt; // Timestamp when collateral was locked
        bool isActive; // Whether collateral is currently locked
    }

    // State variables
    IERC20 public immutable usdt;
    IPriceOracle public priceOracle;
    
    mapping(uint256 => Collateral) public collaterals; // loanId => Collateral
    mapping(address => uint256) public totalEthCollateral; // User => total ETH locked
    mapping(address => uint256) public totalUsdtCollateral; // User => total USDT locked

    // Constants
    uint256 public constant LIQUIDATION_THRESHOLD = 120; // 120% collateral ratio triggers liquidation
    uint256 public constant LIQUIDATOR_REWARD = 5; // 5% reward for liquidators
    uint256 public constant PRICE_STALENESS_THRESHOLD = 1 hours;
    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant PERCENTAGE_BASE = 100;

    // Events
    event CollateralLocked(
        uint256 indexed loanId,
        address indexed borrower,
        CollateralType collateralType,
        uint256 amount,
        uint256 loanAmount
    );
    event CollateralReleased(uint256 indexed loanId, address indexed borrower, uint256 amount);
    event CollateralLiquidated(
        uint256 indexed loanId,
        address indexed liquidator,
        address indexed borrower,
        uint256 collateralAmount,
        uint256 liquidatorReward
    );
    event PriceOracleUpdated(address indexed oldOracle, address indexed newOracle);

    // Errors
    error InvalidCollateralAmount();
    error InvalidLoanAmount();
    error CollateralAlreadyLocked();
    error CollateralNotActive();
    error InsufficientEthSent();
    error LoanNotLiquidatable();
    error StalePriceData();
    error InvalidPriceOracle();
    error CollateralTransferFailed();

    /**
     * @notice Constructor
     * @param _usdt USDT token address
     * @param _priceOracle Price oracle address (Chainlink ETH/USD)
     */
    constructor(address _usdt, address _priceOracle) Ownable(msg.sender) {
        if (_usdt == address(0) || _priceOracle == address(0)) revert InvalidPriceOracle();
        usdt = IERC20(_usdt);
        priceOracle = IPriceOracle(_priceOracle);
    }

    /**
     * @notice Lock ETH collateral for a loan
     * @param loanId The unique loan identifier
     * @param borrower The borrower's address
     * @param loanAmount The USDT loan amount (6 decimals)
     */
    function lockEthCollateral(
        uint256 loanId,
        address borrower,
        uint256 loanAmount
    ) external payable nonReentrant whenNotPaused {
        if (msg.value == 0) revert InvalidCollateralAmount();
        if (loanAmount == 0) revert InvalidLoanAmount();
        if (collaterals[loanId].isActive) revert CollateralAlreadyLocked();

        collaterals[loanId] = Collateral({
            collateralType: CollateralType.ETH,
            amount: msg.value,
            loanAmount: loanAmount,
            lockedAt: block.timestamp,
            isActive: true
        });

        totalEthCollateral[borrower] += msg.value;

        emit CollateralLocked(loanId, borrower, CollateralType.ETH, msg.value, loanAmount);
    }

    /**
     * @notice Lock USDT collateral for a loan
     * @param loanId The unique loan identifier
     * @param borrower The borrower's address
     * @param collateralAmount The USDT collateral amount (6 decimals)
     * @param loanAmount The USDT loan amount (6 decimals)
     */
    function lockUsdtCollateral(
        uint256 loanId,
        address borrower,
        uint256 collateralAmount,
        uint256 loanAmount
    ) external nonReentrant whenNotPaused {
        if (collateralAmount == 0) revert InvalidCollateralAmount();
        if (loanAmount == 0) revert InvalidLoanAmount();
        if (collaterals[loanId].isActive) revert CollateralAlreadyLocked();

        // Transfer USDT from borrower to this contract
        bool success = usdt.transferFrom(msg.sender, address(this), collateralAmount);
        if (!success) revert CollateralTransferFailed();

        collaterals[loanId] = Collateral({
            collateralType: CollateralType.USDT,
            amount: collateralAmount,
            loanAmount: loanAmount,
            lockedAt: block.timestamp,
            isActive: true
        });

        totalUsdtCollateral[borrower] += collateralAmount;

        emit CollateralLocked(loanId, borrower, CollateralType.USDT, collateralAmount, loanAmount);
    }

    /**
     * @notice Release collateral after loan repayment
     * @param loanId The loan identifier
     * @param borrower The borrower's address
     */
    function releaseCollateral(uint256 loanId, address borrower)
        external
        nonReentrant
        whenNotPaused
        onlyOwner
    {
        Collateral storage collateral = collaterals[loanId];
        if (!collateral.isActive) revert CollateralNotActive();

        uint256 amount = collateral.amount;
        CollateralType collateralType = collateral.collateralType;

        // Mark as inactive
        collateral.isActive = false;

        // Update totals
        if (collateralType == CollateralType.ETH) {
            totalEthCollateral[borrower] -= amount;
            (bool success,) = borrower.call{value: amount}("");
            if (!success) revert CollateralTransferFailed();
        } else {
            totalUsdtCollateral[borrower] -= amount;
            bool success = usdt.transfer(borrower, amount);
            if (!success) revert CollateralTransferFailed();
        }

        emit CollateralReleased(loanId, borrower, amount);
    }

    /**
     * @notice Liquidate undercollateralized loan
     * @param loanId The loan identifier
     * @param borrower The borrower's address
     */
    function liquidate(uint256 loanId, address borrower) external nonReentrant whenNotPaused {
        Collateral storage collateral = collaterals[loanId];
        if (!collateral.isActive) revert CollateralNotActive();

        // Check if loan is liquidatable (health ratio < 120%)
        uint256 healthRatio = getHealthRatio(loanId);
        if (healthRatio >= LIQUIDATION_THRESHOLD) revert LoanNotLiquidatable();

        uint256 collateralAmount = collateral.amount;
        CollateralType collateralType = collateral.collateralType;

        // Calculate liquidator reward (5% of collateral)
        uint256 liquidatorReward = (collateralAmount * LIQUIDATOR_REWARD) / PERCENTAGE_BASE;
        uint256 protocolAmount = collateralAmount - liquidatorReward;

        // Mark as inactive
        collateral.isActive = false;

        // Update totals
        if (collateralType == CollateralType.ETH) {
            totalEthCollateral[borrower] -= collateralAmount;
            
            // Send reward to liquidator
            (bool success1,) = msg.sender.call{value: liquidatorReward}("");
            if (!success1) revert CollateralTransferFailed();
            
            // Send remaining to owner (protocol)
            (bool success2,) = owner().call{value: protocolAmount}("");
            if (!success2) revert CollateralTransferFailed();
        } else {
            totalUsdtCollateral[borrower] -= collateralAmount;
            
            // Send reward to liquidator
            bool success1 = usdt.transfer(msg.sender, liquidatorReward);
            if (!success1) revert CollateralTransferFailed();
            
            // Send remaining to owner (protocol)
            bool success2 = usdt.transfer(owner(), protocolAmount);
            if (!success2) revert CollateralTransferFailed();
        }

        emit CollateralLiquidated(loanId, msg.sender, borrower, collateralAmount, liquidatorReward);
    }

    /**
     * @notice Get health ratio for a loan (collateral value / loan value * 100)
     * @param loanId The loan identifier
     * @return healthRatio The health ratio as a percentage
     */
    function getHealthRatio(uint256 loanId) public view returns (uint256) {
        Collateral memory collateral = collaterals[loanId];
        if (!collateral.isActive) return 0;

        uint256 collateralValueUsd;

        if (collateral.collateralType == CollateralType.ETH) {
            // Get ETH price from oracle
            (int256 price, uint8 decimals, uint256 updatedAt) = priceOracle.getLatestPrice();
            
            // Check price staleness (must be updated within last hour)
            if (block.timestamp - updatedAt > PRICE_STALENESS_THRESHOLD) revert StalePriceData();
            if (price <= 0) revert InvalidPriceOracle();

            // Calculate ETH collateral value in USD
            // collateralValueUsd = (ethAmount * ethPrice) / 10^(18 + priceDecimals - 6)
            // We want result in 6 decimals (USDT format)
            collateralValueUsd = (collateral.amount * uint256(price)) / (10 ** (18 + decimals - 6));
        } else {
            // USDT collateral (already in USD with 6 decimals)
            collateralValueUsd = collateral.amount;
        }

        // Health ratio = (collateralValue / loanAmount) * 100
        // Both values are in 6 decimals, so we can directly calculate
        return (collateralValueUsd * PERCENTAGE_BASE) / collateral.loanAmount;
    }

    /**
     * @notice Get collateral value in USD
     * @param loanId The loan identifier
     * @return valueUsd The collateral value in USD (6 decimals)
     */
    function getCollateralValue(uint256 loanId) external view returns (uint256) {
        Collateral memory collateral = collaterals[loanId];
        if (!collateral.isActive) return 0;

        if (collateral.collateralType == CollateralType.ETH) {
            (int256 price, uint8 decimals, uint256 updatedAt) = priceOracle.getLatestPrice();
            
            if (block.timestamp - updatedAt > PRICE_STALENESS_THRESHOLD) revert StalePriceData();
            if (price <= 0) revert InvalidPriceOracle();

            return (collateral.amount * uint256(price)) / (10 ** (18 + decimals - 6));
        } else {
            return collateral.amount;
        }
    }

    /**
     * @notice Check if a loan can be liquidated
     * @param loanId The loan identifier
     * @return True if loan can be liquidated
     */
    function canLiquidate(uint256 loanId) external view returns (bool) {
        if (!collaterals[loanId].isActive) return false;
        
        try this.getHealthRatio(loanId) returns (uint256 healthRatio) {
            return healthRatio < LIQUIDATION_THRESHOLD;
        } catch {
            return false;
        }
    }

    /**
     * @notice Update the price oracle address
     * @param newOracle The new oracle address
     */
    function updatePriceOracle(address newOracle) external onlyOwner {
        if (newOracle == address(0)) revert InvalidPriceOracle();
        address oldOracle = address(priceOracle);
        priceOracle = IPriceOracle(newOracle);
        emit PriceOracleUpdated(oldOracle, newOracle);
    }

    /**
     * @notice Pause the contract (emergency)
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Receive ETH
     */
    receive() external payable {}
}

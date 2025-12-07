// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {CollateralManager} from "./CollateralManager.sol";
import {InterestCalculator} from "./InterestCalculator.sol";
import {CreditScore} from "./CreditScore.sol";
import {LendingPool} from "./LendingPool.sol";

/**
 * @title LoanManager
 * @notice Manages loan lifecycle: creation, repayment, and completion
 * @dev Integrates with CollateralManager, InterestCalculator, CreditScore, and LendingPool
 */
contract LoanManager is ReentrancyGuard, Pausable, Ownable {
    // Loan status enumeration
    enum LoanStatus {
        Active,
        Repaid,
        Defaulted
    }

    // Loan structure
    struct Loan {
        address borrower;
        uint256 amount; // USDT amount (6 decimals)
        uint256 collateralAmount; // Collateral locked
        CollateralManager.CollateralType collateralType;
        InterestCalculator.LoanType loanType;
        uint256 interestRate; // Basis points (10000 = 100%)
        uint256 durationDays;
        uint256 startTime;
        uint256 dueDate;
        uint256 totalRepaid;
        LoanStatus status;
    }

    // State variables
    IERC20 public immutable usdt;
    CollateralManager public immutable collateralManager;
    InterestCalculator public immutable interestCalculator;
    CreditScore public immutable creditScore;
    LendingPool public immutable lendingPool;

    mapping(uint256 => Loan) public loans;
    mapping(address => uint256[]) public userLoans; // User => loan IDs
    uint256 public loanCounter;

    // Protocol fee settings
    uint256 public constant PROTOCOL_FEE_PERCENTAGE = 1000; // 10% in basis points (10000 = 100%)
    address public protocolTreasury;
    uint256 public totalProtocolFeesCollected;

    // Constants
    uint256 public constant MIN_LOAN_AMOUNT = 100e6; // 100 USDT minimum
    uint256 public constant MAX_LOAN_DURATION = 365 days;
    uint256 public constant MIN_LOAN_DURATION = 7 days;
    uint256 public constant LIQUIDATION_GRACE_PERIOD = 3 days; // Grace after due date

    // Events
    event LoanCreated(
        uint256 indexed loanId,
        address indexed borrower,
        uint256 amount,
        uint256 collateralAmount,
        InterestCalculator.LoanType loanType,
        uint256 durationDays
    );
    event LoanRepaid(uint256 indexed loanId, address indexed borrower, uint256 amount, uint256 totalRepaid);
    event LoanCompleted(uint256 indexed loanId, address indexed borrower, uint256 totalAmount);
    event LoanDefaulted(uint256 indexed loanId, address indexed borrower, uint256 outstandingAmount);
    event ProtocolFeeCollected(uint256 indexed loanId, uint256 feeAmount, uint256 totalCollected);
    event ProtocolFeesWithdrawn(address indexed treasury, uint256 amount);
    event ProtocolTreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    // Errors
    error InvalidLoanAmount();
    error InvalidDuration();
    error InsufficientCollateral();
    error LoanNotActive();
    error LoanAlreadyRepaid();
    error InsufficientRepayment();
    error LoanNotDue();
    error InvalidLoanId();
    error NotLoanBorrower();
    error InvalidTreasuryAddress();
    error NoFeesToWithdraw();
    error InsufficientPoolLiquidity();

    /**
     * @notice Constructor
     * @param _usdt USDT token address
     * @param _collateralManager CollateralManager contract address
     * @param _interestCalculator InterestCalculator contract address
     * @param _creditScore CreditScore contract address
     * @param _lendingPool LendingPool contract address
     * @param _protocolTreasury Protocol treasury address for fee collection
     */
    constructor(
        address _usdt,
        address _collateralManager,
        address _interestCalculator,
        address _creditScore,
        address _lendingPool,
        address _protocolTreasury
    ) Ownable(msg.sender) {
        if (_protocolTreasury == address(0)) revert InvalidTreasuryAddress();
        
        usdt = IERC20(_usdt);
        collateralManager = CollateralManager(payable(_collateralManager));
        interestCalculator = InterestCalculator(_interestCalculator);
        creditScore = CreditScore(_creditScore);
        lendingPool = LendingPool(_lendingPool);
        protocolTreasury = _protocolTreasury;
    }

    /**
     * @notice Create a new loan with ETH collateral
     * @param amount Loan amount in USDT (6 decimals)
     * @param loanType Type of loan
     * @param durationDays Loan duration in days
     */
    function createLoanWithEth(uint256 amount, InterestCalculator.LoanType loanType, uint256 durationDays)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        _validateLoanParameters(amount, durationDays);

        // Check pool has sufficient liquidity
        if (lendingPool.getAvailableLiquidity() < amount) revert InsufficientPoolLiquidity();

        // Get required collateral ratio based on credit score
        uint256 requiredRatio = creditScore.getRequiredCollateralRatio(msg.sender);

        // Check if user qualifies for loan amount
        if (!creditScore.qualifiesForLoan(msg.sender, amount)) revert InvalidLoanAmount();

        // Calculate required collateral in USD
        uint256 requiredCollateralUsd = (amount * requiredRatio) / 100;

        // Get ETH value from CollateralManager (uses price oracle)
        loanCounter++;
        uint256 loanId = loanCounter;

        // Lock ETH collateral (will validate amount internally)
        collateralManager.lockEthCollateral{value: msg.value}(loanId, msg.sender, amount);

        // Verify collateral value meets requirement
        uint256 collateralValue = collateralManager.getCollateralValue(loanId);
        if (collateralValue < requiredCollateralUsd) revert InsufficientCollateral();

        // Get interest rate for loan type
        uint256 interestRate = interestCalculator.getLoanTypeRate(loanType);

        // Create loan
        _createLoan(loanId, amount, msg.value, CollateralManager.CollateralType.ETH, loanType, interestRate, durationDays);

        // Transfer USDT from lending pool to borrower
        lendingPool.borrowFromPool(msg.sender, amount);

        // Record loan in credit score
        creditScore.recordLoan(msg.sender, amount);
    }

    /**
     * @notice Create a new loan with USDT collateral
     * @param amount Loan amount in USDT (6 decimals)
     * @param collateralAmount USDT collateral amount (6 decimals)
     * @param loanType Type of loan
     * @param durationDays Loan duration in days
     */
    function createLoanWithUsdt(uint256 amount, uint256 collateralAmount, InterestCalculator.LoanType loanType, uint256 durationDays)
        external
        nonReentrant
        whenNotPaused
    {
        _validateLoanParameters(amount, durationDays);

        // Check pool has sufficient liquidity
        if (lendingPool.getAvailableLiquidity() < amount) revert InsufficientPoolLiquidity();

        // Get required collateral ratio based on credit score
        uint256 requiredRatio = creditScore.getRequiredCollateralRatio(msg.sender);

        // Check if user qualifies for loan amount
        if (!creditScore.qualifiesForLoan(msg.sender, amount)) revert InvalidLoanAmount();

        // Calculate required collateral
        uint256 requiredCollateral = (amount * requiredRatio) / 100;
        if (collateralAmount < requiredCollateral) revert InsufficientCollateral();

        loanCounter++;
        uint256 loanId = loanCounter;

        // Transfer USDT collateral to CollateralManager
        usdt.transferFrom(msg.sender, address(this), collateralAmount);
        usdt.approve(address(collateralManager), collateralAmount);

        // Lock USDT collateral
        collateralManager.lockUsdtCollateral(loanId, msg.sender, collateralAmount, amount);

        // Get interest rate for loan type
        uint256 interestRate = interestCalculator.getLoanTypeRate(loanType);

        // Create loan
        _createLoan(
            loanId, amount, collateralAmount, CollateralManager.CollateralType.USDT, loanType, interestRate, durationDays
        );

        // Transfer USDT from lending pool to borrower
        lendingPool.borrowFromPool(msg.sender, amount);

        // Record loan in credit score
        creditScore.recordLoan(msg.sender, amount);
    }

    /**
     * @notice Repay loan (full or partial)
     * @param loanId The loan identifier
     * @param amount Amount to repay (USDT, 6 decimals)
     */
    function repayLoan(uint256 loanId, uint256 amount) external nonReentrant whenNotPaused {
        Loan storage loan = loans[loanId];

        if (loan.borrower == address(0)) revert InvalidLoanId();
        if (loan.borrower != msg.sender) revert NotLoanBorrower();
        if (loan.status != LoanStatus.Active) revert LoanNotActive();
        if (amount == 0) revert InsufficientRepayment();

        // Calculate total amount due (principal + interest)
        uint256 interest = interestCalculator.calculateInterest(loan.amount, loan.interestRate, loan.durationDays);
        uint256 totalDue = loan.amount + interest;
        uint256 outstanding = totalDue - loan.totalRepaid;

        // Ensure repayment doesn't exceed outstanding amount
        uint256 repaymentAmount = amount > outstanding ? outstanding : amount;

        // Transfer USDT from borrower
        usdt.transferFrom(msg.sender, address(this), repaymentAmount);

        // Update loan
        loan.totalRepaid += repaymentAmount;

        emit LoanRepaid(loanId, msg.sender, repaymentAmount, loan.totalRepaid);

        // Calculate proportional interest for this payment
        uint256 proportionalInterest = (interest * repaymentAmount) / totalDue;
        
        // Split interest: 10% to protocol, 90% to lenders
        uint256 protocolFee = (proportionalInterest * PROTOCOL_FEE_PERCENTAGE) / 10000;
        uint256 lenderInterest = proportionalInterest - protocolFee;
        
        // Track protocol fees (kept in LoanManager)
        totalProtocolFeesCollected += protocolFee;
        emit ProtocolFeeCollected(loanId, protocolFee, totalProtocolFeesCollected);
        
        // Transfer principal + lender interest to lending pool (exclude protocol fee)
        uint256 amountToPool = repaymentAmount - protocolFee;
        usdt.approve(address(lendingPool), amountToPool);
        lendingPool.repayToPool(amountToPool, lenderInterest);

        // Check if loan is fully repaid
        if (loan.totalRepaid >= totalDue) {
            loan.status = LoanStatus.Repaid;

            // Release collateral
            collateralManager.releaseCollateral(loanId, msg.sender);

            // Update credit score
            creditScore.recordRepayment(msg.sender, loan.totalRepaid);

            emit LoanCompleted(loanId, msg.sender, loan.totalRepaid);
        }
    }

    /**
     * @notice Mark loan as defaulted (after grace period)
     * @param loanId The loan identifier
     */
    function defaultLoan(uint256 loanId) external nonReentrant {
        Loan storage loan = loans[loanId];

        if (loan.borrower == address(0)) revert InvalidLoanId();
        if (loan.status != LoanStatus.Active) revert LoanNotActive();

        // Check if loan is past due date + grace period
        if (block.timestamp < loan.dueDate + LIQUIDATION_GRACE_PERIOD) revert LoanNotDue();

        // Calculate outstanding amount
        uint256 interest = interestCalculator.calculateInterest(loan.amount, loan.interestRate, loan.durationDays);
        uint256 totalDue = loan.amount + interest;
        uint256 outstanding = totalDue - loan.totalRepaid;

        // Mark as defaulted
        loan.status = LoanStatus.Defaulted;

        // Liquidate collateral
        collateralManager.liquidate(loanId, loan.borrower);

        // Update credit score
        creditScore.recordDefault(loan.borrower, outstanding);

        emit LoanDefaulted(loanId, loan.borrower, outstanding);
    }

    /**
     * @notice Get loan details
     * @param loanId The loan identifier
     * @return Loan details
     */
    function getLoan(uint256 loanId) external view returns (Loan memory) {
        return loans[loanId];
    }

    /**
     * @notice Get all loan IDs for a user
     * @param user The user's address
     * @return Array of loan IDs
     */
    function getUserLoans(address user) external view returns (uint256[] memory) {
        return userLoans[user];
    }

    /**
     * @notice Get outstanding amount for a loan
     * @param loanId The loan identifier
     * @return outstanding The outstanding amount (principal + interest - repaid)
     */
    function getOutstandingAmount(uint256 loanId) external view returns (uint256) {
        Loan memory loan = loans[loanId];
        if (loan.status != LoanStatus.Active) return 0;

        uint256 interest = interestCalculator.calculateInterest(loan.amount, loan.interestRate, loan.durationDays);
        uint256 totalDue = loan.amount + interest;
        return totalDue > loan.totalRepaid ? totalDue - loan.totalRepaid : 0;
    }

    /**
     * @notice Get total amount due for a loan
     * @param loanId The loan identifier
     * @return totalDue The total amount due (principal + interest)
     */
    function getTotalDue(uint256 loanId) external view returns (uint256) {
        Loan memory loan = loans[loanId];
        uint256 interest = interestCalculator.calculateInterest(loan.amount, loan.interestRate, loan.durationDays);
        return loan.amount + interest;
    }

    /**
     * @notice Check if loan is overdue
     * @param loanId The loan identifier
     * @return True if loan is past due date
     */
    function isOverdue(uint256 loanId) external view returns (bool) {
        Loan memory loan = loans[loanId];
        return loan.status == LoanStatus.Active && block.timestamp > loan.dueDate;
    }

    /**
     * @notice Get active loan count for user
     * @param user The user's address
     * @return count Number of active loans
     */
    function getActiveLoanCount(address user) external view returns (uint256 count) {
        uint256[] memory loanIds = userLoans[user];
        for (uint256 i = 0; i < loanIds.length; i++) {
            if (loans[loanIds[i]].status == LoanStatus.Active) {
                count++;
            }
        }
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

    // ============ Internal Functions ============

    /**
     * @notice Validate loan parameters
     */
    function _validateLoanParameters(uint256 amount, uint256 durationDays) internal pure {
        if (amount < MIN_LOAN_AMOUNT) revert InvalidLoanAmount();
        if (durationDays < MIN_LOAN_DURATION / 1 days || durationDays > MAX_LOAN_DURATION / 1 days) {
            revert InvalidDuration();
        }
    }

    /**
     * @notice Create loan record
     */
    function _createLoan(
        uint256 loanId,
        uint256 amount,
        uint256 collateralAmount,
        CollateralManager.CollateralType collateralType,
        InterestCalculator.LoanType loanType,
        uint256 interestRate,
        uint256 durationDays
    ) internal {
        uint256 dueDate = block.timestamp + (durationDays * 1 days);

        loans[loanId] = Loan({
            borrower: msg.sender,
            amount: amount,
            collateralAmount: collateralAmount,
            collateralType: collateralType,
            loanType: loanType,
            interestRate: interestRate,
            durationDays: durationDays,
            startTime: block.timestamp,
            dueDate: dueDate,
            totalRepaid: 0,
            status: LoanStatus.Active
        });

        userLoans[msg.sender].push(loanId);

        emit LoanCreated(loanId, msg.sender, amount, collateralAmount, loanType, durationDays);
    }

    /**
     * @notice Withdraw collected protocol fees to treasury
     * @dev Only owner can call this function
     */
    function withdrawProtocolFees() external onlyOwner {
        uint256 feesToWithdraw = totalProtocolFeesCollected;
        if (feesToWithdraw == 0) revert NoFeesToWithdraw();

        totalProtocolFeesCollected = 0;
        usdt.transfer(protocolTreasury, feesToWithdraw);

        emit ProtocolFeesWithdrawn(protocolTreasury, feesToWithdraw);
    }

    /**
     * @notice Update protocol treasury address
     * @param newTreasury New treasury address
     * @dev Only owner can call this function
     */
    function updateProtocolTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert InvalidTreasuryAddress();
        
        address oldTreasury = protocolTreasury;
        protocolTreasury = newTreasury;

        emit ProtocolTreasuryUpdated(oldTreasury, newTreasury);
    }

    /**
     * @notice Get protocol fee information
     * @return feePercentage The protocol fee percentage in basis points
     * @return feesCollected Total fees collected and waiting to be withdrawn
     * @return treasury Current treasury address
     */
    function getProtocolFeeInfo() external view returns (uint256 feePercentage, uint256 feesCollected, address treasury) {
        return (PROTOCOL_FEE_PERCENTAGE, totalProtocolFeesCollected, protocolTreasury);
    }

    /**
     * @notice Receive ETH
     */
    receive() external payable {}
}

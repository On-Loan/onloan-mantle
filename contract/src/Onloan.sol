// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract OnLoan is Ownable, ReentrancyGuard, Pausable {
    IERC20 public usdt;  // USDT token
    AggregatorV3Interface public priceFeed;  // Chainlink ETH/USD feed

    enum LoanType { Personal, Home, Business, Auto }

    struct Loan {
        address borrower;
        uint256 amount;  // in USDT
        uint256 collateral;  // in wei (ETH) or USDT
        uint256 interestRate;  // in basis points (e.g., 500 = 5%)
        uint256 duration;  // in seconds
        uint256 startTime;
        uint256 repaidAmount;
        bool isActive;
        bool isCollateralETH;
        LoanType loanType;
    }

    mapping(address => Loan) public userLoans;
    mapping(address => uint256) public borrowLimits;
    mapping(address => uint256) public creditScores;  // 0-1000
    mapping(address => uint256) public lenderBalances;  // Deposited to pool
    uint256 public totalPoolLiquidity;
    uint256 public constant COLLATERAL_RATIO = 150;  // 150%
    uint256 public constant MIN_SCORE = 100;  // Threshold for borrowing
    uint256 public constant INITIAL_LIMIT = 10 * 10**6;  // $10 USDT (assuming 6 decimals)

    event LoanCreated(address indexed borrower, uint256 amount, uint256 duration, LoanType loanType);
    event RepaymentMade(address indexed borrower, uint256 amount);
    event DepositToPool(address indexed lender, uint256 amount);
    event WithdrawalFromPool(address indexed lender, uint256 amount);
    event Liquidated(address indexed borrower, uint256 collateral);

    error InsufficientCollateral();
    error LoanNotDue();
    error InsufficientScore();
    error LoanAlreadyActive();
    error InsufficientPoolLiquidity();
    error InvalidAmount();

    constructor(address _usdtAddress, address _priceFeedAddress) {
        usdt = IERC20(_usdtAddress);
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function depositToPool(uint256 amount) external nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();
        usdt.transferFrom(msg.sender, address(this), amount);
        lenderBalances[msg.sender] += amount;
        totalPoolLiquidity += amount;
        emit DepositToPool(msg.sender, amount);
    }

    function withdrawFromPool(uint256 amount) external nonReentrant whenNotPaused {
        if (amount > lenderBalances[msg.sender]) revert InvalidAmount();
        lenderBalances[msg.sender] -= amount;
        totalPoolLiquidity -= amount;
        usdt.transfer(msg.sender, amount);
        emit WithdrawalFromPool(msg.sender, amount);
    }

    function borrowFromPool(uint256 amount, uint256 duration, LoanType loanType, bool useETHCollateral) external payable nonReentrant whenNotPaused {
        if (creditScores[msg.sender] < MIN_SCORE) revert InsufficientScore();
        if (amount > borrowLimits[msg.sender]) revert InvalidAmount();
        if (amount > totalPoolLiquidity) revert InsufficientPoolLiquidity();
        if (userLoans[msg.sender].isActive) revert LoanAlreadyActive();

        uint256 requiredCollateral = (amount * COLLATERAL_RATIO) / 100;
        if (useETHCollateral) {
            if (msg.value < requiredCollateral) revert InsufficientCollateral();
            // Convert ETH to USD value using Chainlink
            uint256 ethValue = getETHPrice() * msg.value / 1e18;  // Adjust decimals
            if (ethValue < requiredCollateral) revert InsufficientCollateral();
        } else {
            usdt.transferFrom(msg.sender, address(this), requiredCollateral);
        }

        usdt.transfer(msg.sender, amount);
        totalPoolLiquidity -= amount;

        userLoans[msg.sender] = Loan({
            borrower: msg.sender,
            amount: amount,
            collateral: useETHCollateral ? msg.value : requiredCollateral,
            interestRate: getInterestRate(loanType),
            duration: duration,
            startTime: block.timestamp,
            repaidAmount: 0,
            isActive: true,
            isCollateralETH: useETHCollateral,
            loanType: loanType
        });

        emit LoanCreated(msg.sender, amount, duration, loanType);
    }

    function repay(uint256 amount) external nonReentrant whenNotPaused {
        Loan storage loan = userLoans[msg.sender];
        if (!loan.isActive) revert LoanNotDue();
        if (amount == 0) revert InvalidAmount();

        uint256 dueAmount = calculateDueAmount(msg.sender);
        if (amount > dueAmount) amount = dueAmount;

        usdt.transferFrom(msg.sender, address(this), amount);
        loan.repaidAmount += amount;
        totalPoolLiquidity += amount;

        if (loan.repaidAmount >= dueAmount) {
            // Return collateral
            if (loan.isCollateralETH) {
                payable(msg.sender).transfer(loan.collateral);
            } else {
                usdt.transfer(msg.sender, loan.collateral);
            }
            loan.isActive = false;
            updateCreditScore(msg.sender, true);  // Successful repayment
            updateBorrowLimit(msg.sender);
        }

        emit RepaymentMade(msg.sender, amount);
    }

    function liquidate(address borrower) external onlyOwner {
        Loan storage loan = userLoans[borrower];
        if (!loan.isActive) return;

        uint256 collateralValue = loan.isCollateralETH ? getETHPrice() * loan.collateral / 1e18 : loan.collateral;
        uint256 dueAmount = calculateDueAmount(borrower);

        if (collateralValue < (dueAmount * COLLATERAL_RATIO / 100)) {
            // Liquidate
            if (loan.isCollateralETH) {
                // Send ETH to pool or owner
                payable(owner()).transfer(loan.collateral);
            } else {
                usdt.transfer(owner(), loan.collateral);
            }
            loan.isActive = false;
            updateCreditScore(borrower, false);  // Penalty
            emit Liquidated(borrower, loan.collateral);
        }
    }

    function calculateDueAmount(address borrower) public view returns (uint256) {
        Loan memory loan = userLoans[borrower];
        if (!loan.isActive) return 0;
        uint256 timeElapsed = block.timestamp - loan.startTime;
        uint256 interest = (loan.amount * loan.interestRate * timeElapsed) / (10000 * 365 days);  // Simple interest
        return loan.amount + interest - loan.repaidAmount;
    }

    function calculateScore(address user) internal {
        // Simple logic: start at 0, +100 per successful repayment, -200 per default
        // Max 1000
        // In reality, based on history, but for demo
        if (borrowLimits[user] == 0) borrowLimits[user] = INITIAL_LIMIT;
        creditScores[user] = min(1000, borrowLimits[user] / 10**6 * 100);  // Rough example
    }

    function updateCreditScore(address user, bool successful) internal {
        calculateScore(user);  // Recalc
        if (successful) {
            creditScores[user] = min(1000, creditScores[user] + 100);
        } else {
            creditScores[user] = creditScores[user] > 200 ? creditScores[user] - 200 : 0;
        }
    }

    function updateBorrowLimit(address user) internal {
        borrowLimits[user] = borrowLimits[user] * 150 / 100;  // 50% increase
    }

    function getInterestRate(LoanType loanType) pure internal returns (uint256) {
        if (loanType == LoanType.Personal) return 800;  // 8%
        if (loanType == LoanType.Home) return 500;
        if (loanType == LoanType.Business) return 1000;
        return 600;  // Auto
    }

    function getETHPrice() public view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price);  // 8 decimals
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // Accrued interest for lenders (proportional)
    function getAccruedInterest(address lender) public view returns (uint256) {
        if (totalPoolLiquidity == 0) return 0;
        // Simple: 5% APY fixed, prorated
        uint256 timeSinceDeposit = block.timestamp;  // Assume tracked per deposit, but simplified
        return (lenderBalances[lender] * 500 * (block.timestamp - 0)) / (10000 * 365 days);  // Placeholder
    }
}
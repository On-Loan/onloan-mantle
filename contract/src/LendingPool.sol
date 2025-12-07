// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./InterestCalculator.sol";

/**
 * @title LendingPool
 * @notice Manages USDT deposits, withdrawals, and interest distribution for lenders
 * @dev Integrates with InterestCalculator for APY calculations
 */
contract LendingPool is Ownable, ReentrancyGuard, Pausable {
    IERC20 public immutable usdt;
    InterestCalculator public immutable interestCalculator;
    address public loanManager;
    
    // Deposit tracking
    struct Deposit {
        uint256 amount;           // Principal deposited
        uint256 depositTime;      // Timestamp of deposit
        uint256 lastClaimTime;    // Last interest claim timestamp
        uint256 accruedInterest;  // Interest accrued but not claimed
    }
    
    // State variables
    mapping(address => Deposit) public deposits;
    uint256 public totalDeposits;      // Total USDT deposited by lenders
    uint256 public totalBorrowed;      // Total USDT borrowed (set by LoanManager)
    uint256 public totalInterestPaid;  // Cumulative interest paid to lenders
    uint256 public totalInterestEarned;  // Total interest earned but not yet distributed
    uint256 public interestPerDepositStored; // Accumulated interest per deposit token (scaled by 1e18)
    
    mapping(address => uint256) public userInterestPerDepositPaid; // Track what user has been credited
    
    // Events
    event Deposited(address indexed lender, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed lender, uint256 amount, uint256 timestamp);
    event InterestClaimed(address indexed lender, uint256 amount, uint256 timestamp);
    event BorrowedAmountUpdated(uint256 oldAmount, uint256 newAmount);
    event LoanManagerUpdated(address indexed oldManager, address indexed newManager);
    
    // Errors
    error OnlyLoanManager();
    
    // Modifier
    modifier onlyLoanManager() {
        if (msg.sender != loanManager) revert OnlyLoanManager();
        _;
    }
    
    constructor(address _usdt, address _interestCalculator) Ownable(msg.sender) {
        require(_usdt != address(0), "LendingPool: zero USDT address");
        require(_interestCalculator != address(0), "LendingPool: zero calculator address");
        
        usdt = IERC20(_usdt);
        interestCalculator = InterestCalculator(_interestCalculator);
    }
    
    /**
     * @notice Set the loan manager address (only owner)
     * @param _loanManager The loan manager contract address
     */
    function setLoanManager(address _loanManager) external onlyOwner {
        require(_loanManager != address(0), "LendingPool: zero address");
        address oldManager = loanManager;
        loanManager = _loanManager;
        emit LoanManagerUpdated(oldManager, _loanManager);
    }
    
    /**
     * @notice Deposit USDT into lending pool
     * @param amount Amount to deposit (6 decimals)
     */
    function deposit(uint256 amount) 
        external 
        nonReentrant 
        whenNotPaused 
    {
        require(amount > 0, "LendingPool: zero amount");
        
        // Update user's interest from loan repayments before changing deposit
        _updateUserInterest(msg.sender);
        
        Deposit storage userDeposit = deposits[msg.sender];
        
        // Transfer USDT from user
        require(
            usdt.transferFrom(msg.sender, address(this), amount),
            "LendingPool: transfer failed"
        );
        
        // Update deposit
        if (userDeposit.amount == 0) {
            userDeposit.depositTime = block.timestamp;
            userDeposit.lastClaimTime = block.timestamp;
        }
        userDeposit.amount += amount;
        
        // Update pool totals
        totalDeposits += amount;
        
        emit Deposited(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @notice Withdraw USDT from lending pool
     * @param amount Amount to withdraw (6 decimals)
     */
    function withdraw(uint256 amount) 
        external 
        nonReentrant 
        whenNotPaused 
    {
        require(amount > 0, "LendingPool: zero amount");
        
        // Update user's interest from loan repayments before withdrawal
        _updateUserInterest(msg.sender);
        
        Deposit storage userDeposit = deposits[msg.sender];
        require(userDeposit.amount >= amount, "LendingPool: insufficient balance");
        
        // Check available liquidity
        uint256 availableLiquidity = getAvailableLiquidity();
        require(availableLiquidity >= amount, "LendingPool: insufficient liquidity");
        
        // Update deposit
        userDeposit.amount -= amount;
        totalDeposits -= amount;
        
        // Transfer USDT to user
        require(
            usdt.transfer(msg.sender, amount),
            "LendingPool: transfer failed"
        );
        
        emit Withdrawn(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @notice Claim accrued interest
     */
    function claimInterest() 
        external 
        nonReentrant 
        whenNotPaused 
    {
        // Update user's interest from loan repayments
        _updateUserInterest(msg.sender);
        
        Deposit storage userDeposit = deposits[msg.sender];
        uint256 interestAmount = userDeposit.accruedInterest;
        require(interestAmount > 0, "LendingPool: no interest");
        
        // Check available liquidity for interest payment
        uint256 availableLiquidity = getAvailableLiquidity();
        require(availableLiquidity >= interestAmount, "LendingPool: insufficient liquidity");
        
        // Reset accrued interest
        userDeposit.accruedInterest = 0;
        totalInterestPaid += interestAmount;
        
        // Transfer interest
        require(
            usdt.transfer(msg.sender, interestAmount),
            "LendingPool: transfer failed"
        );
        
        emit InterestClaimed(msg.sender, interestAmount, block.timestamp);
    }
    
    /**
     * @notice Update total borrowed amount (called by LoanManager)
     * @param newBorrowedAmount New total borrowed amount
     */
    function updateBorrowedAmount(uint256 newBorrowedAmount) 
        external 
        onlyOwner 
    {
        uint256 oldAmount = totalBorrowed;
        totalBorrowed = newBorrowedAmount;
        
        emit BorrowedAmountUpdated(oldAmount, newBorrowedAmount);
    }
    
    /**
     * @notice Get available liquidity for withdrawals and loans
     * @return liquidity Available USDT amount
     */
    function getAvailableLiquidity() public view returns (uint256 liquidity) {
        uint256 balance = usdt.balanceOf(address(this));
        return balance;
    }
    
    /**
     * @notice Get current pool utilization rate
     * @return utilization Utilization in basis points (0-10000)
     */
    function getUtilizationRate() public view returns (uint256 utilization) {
        return interestCalculator.calculateUtilization(totalBorrowed, totalDeposits);
    }
    
    /**
     * @notice Get current lender APY
     * @return apy Annual percentage yield in basis points
     */
    function getCurrentAPY() public view returns (uint256 apy) {
        uint256 utilization = getUtilizationRate();
        uint256 borrowRate = interestCalculator.calculateBorrowRate(utilization);
        return interestCalculator.calculateLenderAPY(utilization, borrowRate);
    }
    
    /**
     * @notice Calculate pending interest for a lender
     * @param lender Address to check
     * @return pendingInterest Interest amount not yet claimed
     */
    function calculatePendingInterest(address lender) 
        public 
        view 
        returns (uint256 pendingInterest) 
    {
        Deposit storage userDeposit = deposits[lender];
        
        if (userDeposit.amount == 0) {
            return userDeposit.accruedInterest;
        }
        
        // Calculate proportional share of distributed interest
        uint256 earnedInterest = _calculateEarnedInterest(lender);
        
        return userDeposit.accruedInterest + earnedInterest;
    }
    
    /**
     * @notice Calculate interest earned by a lender from loan repayments
     * @param lender Address to calculate for
     * @return earned Interest amount earned but not yet credited
     */
    function _calculateEarnedInterest(address lender) internal view returns (uint256 earned) {
        Deposit storage userDeposit = deposits[lender];
        
        if (userDeposit.amount == 0) {
            return 0;
        }
        
        // Calculate based on proportional share of total deposits
        // Using the stored interest per deposit for accurate tracking
        uint256 interestPerDeposit = interestPerDepositStored;
        uint256 userInterestPerDeposit = userInterestPerDepositPaid[lender];
        
        if (interestPerDeposit > userInterestPerDeposit) {
            uint256 interestPerDepositDelta = interestPerDeposit - userInterestPerDeposit;
            earned = (userDeposit.amount * interestPerDepositDelta) / 1e18;
        }
        
        return earned;
    }
    
    /**
     * @notice Update user's accrued interest from distributed interest
     * @param lender Address to update
     */
    function _updateUserInterest(address lender) internal {
        uint256 earnedInterest = _calculateEarnedInterest(lender);
        
        if (earnedInterest > 0) {
            deposits[lender].accruedInterest += earnedInterest;
        }
        
        // Mark user as up-to-date with current interest distribution
        userInterestPerDepositPaid[lender] = interestPerDepositStored;
    }
    
    /**
     * @notice Get lender's deposit information
     * @param lender Address to query
     * @return amount Deposited amount
     * @return depositTime Timestamp of initial deposit
     * @return pendingInterest Claimable interest
     */
    function getDepositInfo(address lender) 
        external 
        view 
        returns (
            uint256 amount,
            uint256 depositTime,
            uint256 pendingInterest
        ) 
    {
        Deposit storage userDeposit = deposits[lender];
        return (
            userDeposit.amount,
            userDeposit.depositTime,
            calculatePendingInterest(lender)
        );
    }
    
    /**
     * @notice Get pool statistics
     * @return _totalDeposits Total deposits in pool
     * @return _totalBorrowed Total borrowed from pool
     * @return _availableLiquidity Available liquidity
     * @return _utilization Utilization rate
     * @return _apy Current lender APY
     */
    function getPoolStats() 
        external 
        view 
        returns (
            uint256 _totalDeposits,
            uint256 _totalBorrowed,
            uint256 _availableLiquidity,
            uint256 _utilization,
            uint256 _apy
        ) 
    {
        return (
            totalDeposits,
            totalBorrowed,
            getAvailableLiquidity(),
            getUtilizationRate(),
            getCurrentAPY()
        );
    }
    
    /**
     * @notice Borrow USDT from pool (only callable by LoanManager)
     * @param borrower Address of borrower
     * @param amount Amount to borrow
     */
    function borrowFromPool(address borrower, uint256 amount) external onlyLoanManager nonReentrant {
        require(amount > 0, "LendingPool: zero amount");
        require(getAvailableLiquidity() >= amount, "LendingPool: insufficient liquidity");
        
        totalBorrowed += amount;
        
        bool success = usdt.transfer(borrower, amount);
        require(success, "LendingPool: transfer failed");
        
        emit BorrowedAmountUpdated(totalBorrowed - amount, totalBorrowed);
    }
    
    /**
     * @notice Repay borrowed USDT to pool (only callable by LoanManager)
     * @param amount Total amount being repaid (principal + interest)
     * @param interestAmount Interest portion of repayment
     */
    function repayToPool(uint256 amount, uint256 interestAmount) external onlyLoanManager nonReentrant {
        require(amount > 0, "LendingPool: zero amount");
        
        uint256 principalAmount = amount - interestAmount;
        
        // Reduce borrowed amount by principal
        if (principalAmount <= totalBorrowed) {
            totalBorrowed -= principalAmount;
        } else {
            totalBorrowed = 0;
        }
        
        // Track interest paid
        totalInterestPaid += interestAmount;
        
        // Distribute interest to all lenders proportionally
        if (interestAmount > 0 && totalDeposits > 0) {
            _distributeInterest(interestAmount);
        }
        
        // Transfer USDT from LoanManager
        bool success = usdt.transferFrom(msg.sender, address(this), amount);
        require(success, "LendingPool: transfer failed");
        
        emit BorrowedAmountUpdated(totalBorrowed + principalAmount, totalBorrowed);
    }
    
    /**
     * @notice Distribute interest to all lenders proportionally
     * @param interestAmount Total interest to distribute
     */
    function _distributeInterest(uint256 interestAmount) internal {
        // Update the accumulated interest per deposit token
        // This allows each lender to claim their proportional share
        if (totalDeposits > 0) {
            // Scale by 1e18 for precision
            uint256 interestPerDeposit = (interestAmount * 1e18) / totalDeposits;
            interestPerDepositStored += interestPerDeposit;
            totalInterestEarned += interestAmount;
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
}

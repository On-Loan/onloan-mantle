// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title InterestCalculator
 * @notice Calculates interest rates based on pool utilization and loan types
 * @dev Pure calculation contract with no state - gas efficient for queries
 */
contract InterestCalculator {
    // Basis points for percentage calculations (100% = 10000 BP)
    uint256 public constant BASIS_POINTS = 10000;
    
    // Base interest rate: 3%
    uint256 public constant BASE_RATE = 300; // 3%
    
    // Optimal utilization: 80%
    uint256 public constant OPTIMAL_UTILIZATION = 8000; // 80%
    
    // Slope factors for rate calculation
    uint256 public constant SLOPE_1 = 400; // 4% up to optimal
    uint256 public constant SLOPE_2 = 6000; // 60% above optimal (steep)
    
    // Loan type specific rates (annual percentage rates in basis points)
    enum LoanType { Personal, Home, Business, Auto }
    
    /**
     * @notice Calculate borrow rate based on pool utilization
     * @param utilization Current utilization rate in basis points (0-10000)
     * @return rate Annual borrow rate in basis points
     */
    function calculateBorrowRate(uint256 utilization) 
        public 
        pure 
        returns (uint256 rate) 
    {
        require(utilization <= BASIS_POINTS, "InterestCalculator: invalid utilization");
        
        if (utilization <= OPTIMAL_UTILIZATION) {
            // Below optimal: gradual increase
            // Rate = BASE_RATE + (utilization * SLOPE_1 / OPTIMAL_UTILIZATION)
            rate = BASE_RATE + (utilization * SLOPE_1) / OPTIMAL_UTILIZATION;
        } else {
            // Above optimal: steep increase to discourage over-borrowing
            uint256 excessUtilization = utilization - OPTIMAL_UTILIZATION;
            uint256 maxExcess = BASIS_POINTS - OPTIMAL_UTILIZATION;
            
            // Rate = BASE_RATE + SLOPE_1 + (excessUtilization * SLOPE_2 / maxExcess)
            rate = BASE_RATE + SLOPE_1 + (excessUtilization * SLOPE_2) / maxExcess;
        }
        
        return rate;
    }
    
    /**
     * @notice Calculate lender APY based on utilization and borrow rate
     * @param utilization Current utilization rate in basis points
     * @param borrowRate Current borrow rate in basis points
     * @return apy Annual percentage yield for lenders in basis points
     */
    function calculateLenderAPY(uint256 utilization, uint256 borrowRate)
        public
        pure
        returns (uint256 apy)
    {
        require(utilization <= BASIS_POINTS, "InterestCalculator: invalid utilization");
        
        // Lender APY = borrowRate * utilization / BASIS_POINTS
        // (Interest earned is proportional to how much is borrowed)
        apy = (borrowRate * utilization) / BASIS_POINTS;
        
        return apy;
    }
    
    /**
     * @notice Get base interest rate for specific loan type
     * @param loanType Type of loan
     * @return rate Base rate for loan type in basis points
     */
    function getLoanTypeRate(LoanType loanType) 
        public 
        pure 
        returns (uint256 rate) 
    {
        if (loanType == LoanType.Personal) {
            return 800; // 8%
        } else if (loanType == LoanType.Home) {
            return 500; // 5%
        } else if (loanType == LoanType.Business) {
            return 1000; // 10%
        } else if (loanType == LoanType.Auto) {
            return 600; // 6%
        }
        
        revert("InterestCalculator: invalid loan type");
    }
    
    /**
     * @notice Calculate total interest for a loan
     * @param principal Loan amount in USDT (6 decimals)
     * @param rate Annual interest rate in basis points
     * @param durationDays Loan duration in days
     * @return interest Total interest amount in USDT (6 decimals)
     */
    function calculateInterest(
        uint256 principal,
        uint256 rate,
        uint256 durationDays
    ) 
        public 
        pure 
        returns (uint256 interest) 
    {
        require(principal > 0, "InterestCalculator: zero principal");
        require(durationDays > 0, "InterestCalculator: zero duration");
        require(durationDays <= 365, "InterestCalculator: duration too long");
        
        // Interest = principal * rate * days / (BASIS_POINTS * 365)
        interest = (principal * rate * durationDays) / (BASIS_POINTS * 365);
        
        return interest;
    }
    
    /**
     * @notice Calculate accrued interest based on time elapsed
     * @param principal Loan amount in USDT (6 decimals)
     * @param rate Annual interest rate in basis points
     * @param timeElapsed Time elapsed in seconds
     * @return accruedInterest Interest accrued in USDT (6 decimals)
     */
    function calculateAccruedInterest(
        uint256 principal,
        uint256 rate,
        uint256 timeElapsed
    )
        public
        pure
        returns (uint256 accruedInterest)
    {
        require(principal > 0, "InterestCalculator: zero principal");
        
        // Convert seconds to days (for annual rate calculation)
        uint256 secondsPerYear = 365 days;
        
        // AccruedInterest = principal * rate * timeElapsed / (BASIS_POINTS * secondsPerYear)
        accruedInterest = (principal * rate * timeElapsed) / (BASIS_POINTS * secondsPerYear);
        
        return accruedInterest;
    }
    
    /**
     * @notice Calculate pool utilization rate
     * @param totalBorrowed Total amount borrowed from pool
     * @param totalLiquidity Total liquidity in pool
     * @return utilization Utilization rate in basis points (0-10000)
     */
    function calculateUtilization(uint256 totalBorrowed, uint256 totalLiquidity)
        public
        pure
        returns (uint256 utilization)
    {
        if (totalLiquidity == 0) {
            return 0;
        }
        
        // Utilization = (totalBorrowed * BASIS_POINTS) / totalLiquidity
        utilization = (totalBorrowed * BASIS_POINTS) / totalLiquidity;
        
        // Cap at 100%
        if (utilization > BASIS_POINTS) {
            utilization = BASIS_POINTS;
        }
        
        return utilization;
    }
}

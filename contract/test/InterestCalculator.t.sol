// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/InterestCalculator.sol";

contract InterestCalculatorTest is Test {
    InterestCalculator public calculator;
    
    uint256 constant BASIS_POINTS = 10000;
    uint256 constant BASE_RATE = 300;
    uint256 constant OPTIMAL_UTILIZATION = 8000;
    
    function setUp() public {
        calculator = new InterestCalculator();
    }
    
    function test_Constants() public view {
        assertEq(calculator.BASIS_POINTS(), 10000);
        assertEq(calculator.BASE_RATE(), 300);
        assertEq(calculator.OPTIMAL_UTILIZATION(), 8000);
        assertEq(calculator.SLOPE_1(), 400);
        assertEq(calculator.SLOPE_2(), 6000);
    }
    
    function test_CalculateBorrowRate_ZeroUtilization() public view {
        uint256 rate = calculator.calculateBorrowRate(0);
        assertEq(rate, BASE_RATE); // 3%
    }
    
    function test_CalculateBorrowRate_BelowOptimal() public view {
        // 50% utilization
        uint256 rate = calculator.calculateBorrowRate(5000);
        
        // Expected: BASE_RATE + (5000 * 400 / 8000) = 300 + 250 = 550
        assertEq(rate, 550);
    }
    
    function test_CalculateBorrowRate_AtOptimal() public view {
        uint256 rate = calculator.calculateBorrowRate(OPTIMAL_UTILIZATION);
        
        // Expected: BASE_RATE + SLOPE_1 = 300 + 400 = 700
        assertEq(rate, 700);
    }
    
    function test_CalculateBorrowRate_AboveOptimal() public view {
        // 90% utilization
        uint256 rate = calculator.calculateBorrowRate(9000);
        
        // excessUtilization = 9000 - 8000 = 1000
        // maxExcess = 10000 - 8000 = 2000
        // Expected: 300 + 400 + (1000 * 6000 / 2000) = 300 + 400 + 3000 = 3700
        assertEq(rate, 3700);
    }
    
    function test_CalculateBorrowRate_MaxUtilization() public view {
        uint256 rate = calculator.calculateBorrowRate(BASIS_POINTS);
        
        // Expected: BASE_RATE + SLOPE_1 + SLOPE_2 = 300 + 400 + 6000 = 6700
        assertEq(rate, 6700);
    }
    
    function test_RevertCalculateBorrowRate_ExcessUtilization() public {
        vm.expectRevert("InterestCalculator: invalid utilization");
        calculator.calculateBorrowRate(BASIS_POINTS + 1);
    }
    
    function test_CalculateLenderAPY_ZeroUtilization() public view {
        uint256 apy = calculator.calculateLenderAPY(0, 500);
        assertEq(apy, 0);
    }
    
    function test_CalculateLenderAPY() public view {
        // 50% utilization, 5% borrow rate
        uint256 apy = calculator.calculateLenderAPY(5000, 500);
        
        // Expected: 500 * 5000 / 10000 = 250 (2.5%)
        assertEq(apy, 250);
    }
    
    function test_CalculateLenderAPY_FullUtilization() public view {
        // 100% utilization, 10% borrow rate
        uint256 apy = calculator.calculateLenderAPY(10000, 1000);
        
        // Expected: 1000 * 10000 / 10000 = 1000 (10%)
        assertEq(apy, 1000);
    }
    
    function test_RevertCalculateLenderAPY_InvalidUtilization() public {
        vm.expectRevert("InterestCalculator: invalid utilization");
        calculator.calculateLenderAPY(BASIS_POINTS + 1, 500);
    }
    
    function test_GetLoanTypeRate_Personal() public view {
        uint256 rate = calculator.getLoanTypeRate(InterestCalculator.LoanType.Personal);
        assertEq(rate, 800); // 8%
    }
    
    function test_GetLoanTypeRate_Home() public view {
        uint256 rate = calculator.getLoanTypeRate(InterestCalculator.LoanType.Home);
        assertEq(rate, 500); // 5%
    }
    
    function test_GetLoanTypeRate_Business() public view {
        uint256 rate = calculator.getLoanTypeRate(InterestCalculator.LoanType.Business);
        assertEq(rate, 1000); // 10%
    }
    
    function test_GetLoanTypeRate_Auto() public view {
        uint256 rate = calculator.getLoanTypeRate(InterestCalculator.LoanType.Auto);
        assertEq(rate, 600); // 6%
    }
    
    function test_CalculateInterest() public view {
        // 1000 USDT, 10% rate, 365 days
        uint256 interest = calculator.calculateInterest(
            1000 * 10 ** 6,
            1000,
            365
        );
        
        // Expected: 1000 * 1000 * 365 / (10000 * 365) = 100 USDT
        assertEq(interest, 100 * 10 ** 6);
    }
    
    function test_CalculateInterest_HalfYear() public view {
        // 1000 USDT, 10% rate, 182.5 days
        uint256 interest = calculator.calculateInterest(
            1000 * 10 ** 6,
            1000,
            182
        );
        
        // Expected: approximately 50 USDT
        assertApproxEqAbs(interest, 50 * 10 ** 6, 0.5 * 10 ** 6);
    }
    
    function test_CalculateInterest_30Days() public view {
        // 10000 USDT, 8% rate, 30 days
        uint256 interest = calculator.calculateInterest(
            10000 * 10 ** 6,
            800,
            30
        );
        
        // Expected: 10000 * 800 * 30 / (10000 * 365) ≈ 65.75 USDT
        assertApproxEqAbs(interest, 65.75 * 10 ** 6, 1 * 10 ** 6);
    }
    
    function test_RevertCalculateInterest_ZeroPrincipal() public {
        vm.expectRevert("InterestCalculator: zero principal");
        calculator.calculateInterest(0, 500, 30);
    }
    
    function test_RevertCalculateInterest_ZeroDuration() public {
        vm.expectRevert("InterestCalculator: zero duration");
        calculator.calculateInterest(1000 * 10 ** 6, 500, 0);
    }
    
    function test_RevertCalculateInterest_DurationTooLong() public {
        vm.expectRevert("InterestCalculator: duration too long");
        calculator.calculateInterest(1000 * 10 ** 6, 500, 366);
    }
    
    function test_CalculateAccruedInterest() public view {
        // 1000 USDT, 10% rate, 365 days in seconds
        uint256 interest = calculator.calculateAccruedInterest(
            1000 * 10 ** 6,
            1000,
            365 days
        );
        
        // Expected: 100 USDT
        assertEq(interest, 100 * 10 ** 6);
    }
    
    function test_CalculateAccruedInterest_OneDay() public view {
        // 1000 USDT, 10% rate, 1 day
        uint256 interest = calculator.calculateAccruedInterest(
            1000 * 10 ** 6,
            1000,
            1 days
        );
        
        // Expected: 1000 * 1000 * 86400 / (10000 * 31536000) ≈ 0.274 USDT
        assertApproxEqAbs(interest, 0.274 * 10 ** 6, 0.01 * 10 ** 6);
    }
    
    function test_CalculateAccruedInterest_OneHour() public view {
        // 10000 USDT, 8% rate, 1 hour
        uint256 interest = calculator.calculateAccruedInterest(
            10000 * 10 ** 6,
            800,
            1 hours
        );
        
        // Expected: very small amount
        assertGt(interest, 0);
    }
    
    function test_RevertCalculateAccruedInterest_ZeroPrincipal() public {
        vm.expectRevert("InterestCalculator: zero principal");
        calculator.calculateAccruedInterest(0, 500, 1 days);
    }
    
    function test_CalculateUtilization_ZeroLiquidity() public view {
        uint256 utilization = calculator.calculateUtilization(0, 0);
        assertEq(utilization, 0);
    }
    
    function test_CalculateUtilization_HalfUtilized() public view {
        uint256 utilization = calculator.calculateUtilization(
            5000 * 10 ** 6,
            10000 * 10 ** 6
        );
        assertEq(utilization, 5000); // 50%
    }
    
    function test_CalculateUtilization_FullyUtilized() public view {
        uint256 utilization = calculator.calculateUtilization(
            10000 * 10 ** 6,
            10000 * 10 ** 6
        );
        assertEq(utilization, 10000); // 100%
    }
    
    function test_CalculateUtilization_OverUtilized_Capped() public view {
        // Edge case: borrowed > liquidity (should cap at 100%)
        uint256 utilization = calculator.calculateUtilization(
            15000 * 10 ** 6,
            10000 * 10 ** 6
        );
        assertEq(utilization, 10000); // Capped at 100%
    }
    
    function testFuzz_CalculateBorrowRate(uint256 utilization) public view {
        utilization = bound(utilization, 0, BASIS_POINTS);
        
        uint256 rate = calculator.calculateBorrowRate(utilization);
        
        // Rate should always be >= BASE_RATE
        assertGe(rate, BASE_RATE);
        
        // Rate should be greater than BASE_RATE when utilization is substantial
        if (utilization >= 100) { // Only check for utilization >= 1%
            assertGt(rate, BASE_RATE);
        }
    }
    
    function testFuzz_CalculateInterest(
        uint256 principal,
        uint256 rate,
        uint256 durationDays
    ) public view {
        principal = bound(principal, 1, 1_000_000 * 10 ** 6); // 1 to 1M USDT
        rate = bound(rate, 1, 10000); // 0.01% to 100%
        durationDays = bound(durationDays, 1, 365);
        
        uint256 interest = calculator.calculateInterest(principal, rate, durationDays);
        
        // Interest should be reasonable
        assertLe(interest, principal); // Interest shouldn't exceed principal for 1 year
    }
}

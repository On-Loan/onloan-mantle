// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {LoanManager} from "../src/LoanManager.sol";
import {CollateralManager} from "../src/CollateralManager.sol";
import {InterestCalculator} from "../src/InterestCalculator.sol";
import {CreditScore} from "../src/CreditScore.sol";
import {LendingPool} from "../src/LendingPool.sol";
import {MockUSDT} from "../src/MockUSDT.sol";
import {MockPriceFeed} from "./mocks/MockPriceFeed.sol";

/**
 * @title Integration Test
 * @notice Tests complete user journey: deposit → borrow → repay
 */
contract IntegrationTest is Test {
    LoanManager public loanManager;
    CollateralManager public collateralManager;
    InterestCalculator public interestCalculator;
    CreditScore public creditScore;
    LendingPool public lendingPool;
    MockUSDT public usdt;
    MockPriceFeed public priceFeed;

    address public owner = address(this);
    address public lender1 = address(0x1);
    address public lender2 = address(0x2);
    address public borrower1 = address(0x3);
    address public borrower2 = address(0x4);
    address public liquidator = address(0x5);

    uint256 public constant ETH_PRICE = 2000e8;

    function setUp() public {
        // Deploy all contracts
        usdt = new MockUSDT();
        priceFeed = new MockPriceFeed(int256(ETH_PRICE), 8, "ETH / USD");
        interestCalculator = new InterestCalculator();
        creditScore = new CreditScore();
        collateralManager = new CollateralManager(address(usdt), address(priceFeed));
        lendingPool = new LendingPool(address(usdt), address(interestCalculator));
        
        loanManager = new LoanManager(
            address(usdt),
            address(collateralManager),
            address(interestCalculator),
            address(creditScore),
            address(lendingPool),
            address(this) // Protocol treasury
        );

        // Setup permissions
        creditScore.setLoanManager(address(loanManager));
        collateralManager.transferOwnership(address(loanManager));
        lendingPool.setLoanManager(address(loanManager));

        // Fund actors
        usdt.mint(lender1, 100000e6);
        usdt.mint(lender2, 50000e6);
        usdt.mint(borrower1, 10000e6);
        usdt.mint(borrower2, 10000e6);
        vm.deal(borrower1, 100 ether);
        vm.deal(borrower2, 100 ether);
        vm.deal(liquidator, 10 ether);
    }

    // ============ Full Lifecycle: Single Lender, Single Borrower ============

    function test_Integration_FullCycle_SingleLoan() public {
        // Step 1: Lender deposits USDT
        vm.startPrank(lender1);
        usdt.approve(address(lendingPool), 100000e6);
        lendingPool.deposit(100000e6);
        vm.stopPrank();

        assertEq(lendingPool.totalDeposits(), 100000e6);
        assertEq(lendingPool.getAvailableLiquidity(), 100000e6);

        // Step 2: Borrower creates loan with ETH collateral
        uint256 loanAmount = 5000e6; // $5000 loan
        uint256 requiredCollateral = (loanAmount * 140) / 100; // 140% for new user
        uint256 ethCollateral = (requiredCollateral * 1e20) / uint256(ETH_PRICE);

        vm.prank(borrower1);
        loanManager.createLoanWithEth{value: ethCollateral}(
            loanAmount,
            InterestCalculator.LoanType.Personal,
            90 // 90 days
        );

        // Verify loan created
        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(loan.amount, loanAmount);
        assertEq(loan.borrower, borrower1);

        // Verify borrower received USDT
        assertEq(usdt.balanceOf(borrower1), 10000e6 + loanAmount);

        // Verify pool state updated
        assertEq(lendingPool.totalBorrowed(), loanAmount);
        assertEq(lendingPool.getAvailableLiquidity(), 100000e6 - loanAmount);

        // Verify credit score recorded
        (, uint256 totalLoans,,,,) = creditScore.getUserData(borrower1);
        assertEq(totalLoans, 1);

        // Step 3: Fast forward time to accrue interest for lender (30 days to accumulate meaningful interest)
        vm.warp(block.timestamp + 30 days);

        // Step 4: Borrower repays loan
        uint256 totalDue = loanManager.getTotalDue(1);
        
        vm.startPrank(borrower1);
        usdt.approve(address(loanManager), totalDue);
        loanManager.repayLoan(1, totalDue);
        vm.stopPrank();

        // Verify loan repaid
        loan = loanManager.getLoan(1);
        assertEq(uint256(loan.status), uint256(LoanManager.LoanStatus.Repaid));

        // Verify collateral returned
        assertTrue(borrower1.balance > 0);

        // Verify credit score improved
        uint256 score = creditScore.getScore(borrower1);
        assertEq(score, 510); // 500 + 10

        // Verify pool received repayment
        assertTrue(lendingPool.totalBorrowed() == 0);
        assertTrue(lendingPool.getAvailableLiquidity() > 95000e6); // Original - loan + interest

        // Step 5: Lender claims interest earned from loan repayment
        uint256 pendingInterest = lendingPool.calculatePendingInterest(lender1);
        assertTrue(pendingInterest > 0, "Lender should have earned interest");
        
        vm.prank(lender1);
        lendingPool.claimInterest();

        // Verify lender got interest
        (,, uint256 lastClaimTime, uint256 accruedInterest) = lendingPool.deposits(lender1);
        assertEq(accruedInterest, 0); // Claimed
        assertTrue(lastClaimTime > 0);
    }

    // ============ Multiple Lenders and Borrowers ============

    function test_Integration_MultipleLendersAndBorrowers() public {
        // Lender 1 deposits $100k
        vm.startPrank(lender1);
        usdt.approve(address(lendingPool), 100000e6);
        lendingPool.deposit(100000e6);
        vm.stopPrank();

        // Lender 2 deposits $50k
        vm.startPrank(lender2);
        usdt.approve(address(lendingPool), 50000e6);
        lendingPool.deposit(50000e6);
        vm.stopPrank();

        assertEq(lendingPool.totalDeposits(), 150000e6);

        // Borrower 1 takes $5k loan
        uint256 loan1Amount = 5000e6;
        uint256 eth1 = ((loan1Amount * 140) / 100) * 1e20 / uint256(ETH_PRICE);
        
        vm.prank(borrower1);
        loanManager.createLoanWithEth{value: eth1}(loan1Amount, InterestCalculator.LoanType.Personal, 30);

        // Borrower 2 takes $3k loan
        uint256 loan2Amount = 3000e6;
        uint256 eth2 = ((loan2Amount * 140) / 100) * 1e20 / uint256(ETH_PRICE);
        
        vm.prank(borrower2);
        loanManager.createLoanWithEth{value: eth2}(loan2Amount, InterestCalculator.LoanType.Home, 60);

        // Verify pool state
        assertEq(lendingPool.totalBorrowed(), loan1Amount + loan2Amount);
        assertEq(lendingPool.getAvailableLiquidity(), 150000e6 - 8000e6);

        // Borrower 1 repays
        uint256 totalDue1 = loanManager.getTotalDue(1);
        vm.startPrank(borrower1);
        usdt.approve(address(loanManager), totalDue1);
        loanManager.repayLoan(1, totalDue1);
        vm.stopPrank();

        // Borrower 2 repays
        uint256 totalDue2 = loanManager.getTotalDue(2);
        vm.startPrank(borrower2);
        usdt.approve(address(loanManager), totalDue2);
        loanManager.repayLoan(2, totalDue2);
        vm.stopPrank();

        // Both lenders can withdraw
        (uint256 lender1Deposit,,,) = lendingPool.deposits(lender1);
        (uint256 lender2Deposit,,,) = lendingPool.deposits(lender2);

        assertTrue(lender1Deposit > 0);
        assertTrue(lender2Deposit > 0);
    }

    // ============ Credit Score Progression ============

    function test_Integration_CreditScoreProgression() public {
        // Setup pool
        vm.startPrank(lender1);
        usdt.approve(address(lendingPool), 100000e6);
        lendingPool.deposit(100000e6);
        vm.stopPrank();

        // Initial score
        uint256 initialScore = creditScore.getScore(borrower1);
        assertEq(initialScore, 500);

        // Take and repay first loan
        vm.prank(borrower1);
        loanManager.createLoanWithEth{value: 1 ether}(1000e6, InterestCalculator.LoanType.Personal, 30);

        uint256 totalDue = loanManager.getTotalDue(1);
        vm.startPrank(borrower1);
        usdt.approve(address(loanManager), totalDue);
        loanManager.repayLoan(1, totalDue);
        vm.stopPrank();

        uint256 scoreAfterOne = creditScore.getScore(borrower1);
        assertEq(scoreAfterOne, 510);

        // Take and repay 4 more loans (should trigger bonus on 5th)
        for (uint256 i = 0; i < 4; i++) {
            vm.prank(borrower1);
            loanManager.createLoanWithEth{value: 1 ether}(1000e6, InterestCalculator.LoanType.Personal, 30);

            totalDue = loanManager.getTotalDue(i + 2);
            vm.startPrank(borrower1);
            usdt.approve(address(loanManager), totalDue);
            loanManager.repayLoan(i + 2, totalDue);
            vm.stopPrank();
        }

        uint256 finalScore = creditScore.getScore(borrower1);
        // 500 + (4 * 10) + (10 + 50 bonus) = 600
        assertEq(finalScore, 600);

        // Verify improved collateral requirements
        uint256 newRatio = creditScore.getRequiredCollateralRatio(borrower1);
        assertEq(newRatio, 120); // Good tier
    }

    // ============ Liquidation Scenario ============

    function test_Integration_LiquidationFlow() public {
        // Setup pool
        vm.startPrank(lender1);
        usdt.approve(address(lendingPool), 100000e6);
        lendingPool.deposit(100000e6);
        vm.stopPrank();

        // Borrower creates loan
        uint256 loanAmount = 1000e6;
        vm.prank(borrower1);
        loanManager.createLoanWithEth{value: 1 ether}(loanAmount, InterestCalculator.LoanType.Personal, 30);

        // Price drops significantly
        priceFeed.setPrice(1100e8); // $1100 ETH

        // Verify loan is now liquidatable
        uint256 healthRatio = collateralManager.getHealthRatio(1);
        assertTrue(healthRatio < 120);

        // Fast forward past grace period
        vm.warp(block.timestamp + 35 days);
        
        // Update oracle to prevent stale price error
        priceFeed.setPrice(1100e8);

        // Anyone can trigger default
        vm.prank(liquidator);
        loanManager.defaultLoan(1);

        // Verify liquidation
        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(uint256(loan.status), uint256(LoanManager.LoanStatus.Defaulted));

        // Verify credit score decreased
        uint256 score = creditScore.getScore(borrower1);
        assertTrue(score < 500);
    }

    // ============ Partial Repayments ============

    function test_Integration_PartialRepayments() public {
        // Setup
        vm.startPrank(lender1);
        usdt.approve(address(lendingPool), 100000e6);
        lendingPool.deposit(100000e6);
        vm.stopPrank();

        // Create loan with sufficient collateral (need 140% = $7000 = 3.5 ETH)
        vm.prank(borrower1);
        loanManager.createLoanWithEth{value: 4 ether}(5000e6, InterestCalculator.LoanType.Personal, 90);

        uint256 totalDue = loanManager.getTotalDue(1);

        // Make 3 partial payments
        uint256 payment1 = totalDue / 3;
        uint256 payment2 = totalDue / 3;
        uint256 payment3 = totalDue - payment1 - payment2; // Remaining

        vm.startPrank(borrower1);
        
        // Payment 1
        usdt.approve(address(loanManager), payment1);
        loanManager.repayLoan(1, payment1);
        
        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(uint256(loan.status), uint256(LoanManager.LoanStatus.Active));
        assertEq(loan.totalRepaid, payment1);

        // Payment 2
        usdt.approve(address(loanManager), payment2);
        loanManager.repayLoan(1, payment2);
        
        loan = loanManager.getLoan(1);
        assertEq(uint256(loan.status), uint256(LoanManager.LoanStatus.Active));

        // Payment 3 (final)
        usdt.approve(address(loanManager), payment3);
        loanManager.repayLoan(1, payment3);
        
        vm.stopPrank();

        loan = loanManager.getLoan(1);
        assertEq(uint256(loan.status), uint256(LoanManager.LoanStatus.Repaid));
        assertEq(loan.totalRepaid, totalDue);
    }

    // ============ Pool Utilization ============

    function test_Integration_PoolUtilization() public {
        // Lender deposits
        vm.startPrank(lender1);
        usdt.approve(address(lendingPool), 100000e6);
        lendingPool.deposit(100000e6);
        vm.stopPrank();

        // Initial utilization is 0%
        assertEq(lendingPool.getUtilizationRate(), 0);

        // Borrower 1 borrows 5k (5% utilization = 500 basis points) - max for new user
        vm.prank(borrower1);
        loanManager.createLoanWithEth{value: 4 ether}(
            5000e6,
            InterestCalculator.LoanType.Personal,
            30
        );

        uint256 utilization = lendingPool.getUtilizationRate();
        assertEq(utilization, 500); // 5% = 500 basis points

        // Borrower 2 borrows 5k (10% utilization total = 1000 basis points)
        vm.prank(borrower2);
        loanManager.createLoanWithEth{value: 4 ether}(
            5000e6,
            InterestCalculator.LoanType.Personal,
            30
        );

        utilization = lendingPool.getUtilizationRate();
        assertEq(utilization, 1000); // 10% = 1000 basis points

        // Check APY increased with utilization
        uint256 apy = lendingPool.getCurrentAPY();
        assertTrue(apy > 0);
    }

    // ============ Multiple Loan Types ============

    function test_Integration_MultipleLoanTypes() public {
        vm.startPrank(lender1);
        usdt.approve(address(lendingPool), 100000e6);
        lendingPool.deposit(100000e6);
        vm.stopPrank();

        uint256 loanAmount = 2000e6;
        uint256 ethNeeded = ((loanAmount * 140) / 100) * 1e20 / uint256(ETH_PRICE);

        // Create different loan types
        vm.startPrank(borrower1);
        
        loanManager.createLoanWithEth{value: ethNeeded}(
            loanAmount,
            InterestCalculator.LoanType.Personal, // 8%
            30
        );

        loanManager.createLoanWithEth{value: ethNeeded}(
            loanAmount,
            InterestCalculator.LoanType.Home, // 5%
            30
        );

        loanManager.createLoanWithEth{value: ethNeeded}(
            loanAmount,
            InterestCalculator.LoanType.Business, // 10%
            30
        );

        loanManager.createLoanWithEth{value: ethNeeded}(
            loanAmount,
            InterestCalculator.LoanType.Auto, // 6%
            30
        );

        vm.stopPrank();

        // Verify different interest amounts
        uint256 due1 = loanManager.getTotalDue(1);
        uint256 due2 = loanManager.getTotalDue(2);
        uint256 due3 = loanManager.getTotalDue(3);
        uint256 due4 = loanManager.getTotalDue(4);

        assertTrue(due3 > due1); // Business > Personal
        assertTrue(due1 > due4); // Personal > Auto
        assertTrue(due4 > due2); // Auto > Home
    }

    // ============ Edge Case: Overpayment ============

    function test_Integration_Overpayment() public {
        vm.startPrank(lender1);
        usdt.approve(address(lendingPool), 100000e6);
        lendingPool.deposit(100000e6);
        vm.stopPrank();

        vm.prank(borrower1);
        loanManager.createLoanWithEth{value: 1 ether}(1000e6, InterestCalculator.LoanType.Personal, 30);

        uint256 totalDue = loanManager.getTotalDue(1);
        uint256 overpayment = totalDue + 500e6; // Try to pay 500 USDT extra

        uint256 borrowerBalanceBefore = usdt.balanceOf(borrower1);

        vm.startPrank(borrower1);
        usdt.approve(address(loanManager), overpayment);
        loanManager.repayLoan(1, overpayment);
        vm.stopPrank();

        // Should only deduct totalDue, not overpayment
        uint256 borrowerBalanceAfter = usdt.balanceOf(borrower1);
        assertEq(borrowerBalanceBefore - borrowerBalanceAfter, totalDue);

        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(loan.totalRepaid, totalDue);
    }

    receive() external payable {}
}

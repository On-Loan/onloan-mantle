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

contract LoanManagerTest is Test {
    LoanManager public loanManager;
    CollateralManager public collateralManager;
    InterestCalculator public interestCalculator;
    CreditScore public creditScore;
    LendingPool public lendingPool;
    MockUSDT public usdt;
    MockPriceFeed public priceFeed;

    address public owner = address(this);
    address public borrower = address(0x1);
    address public lender = address(0x2);

    uint256 public constant ETH_PRICE = 2000e8; // $2000 with 8 decimals
    uint256 public constant LOAN_AMOUNT = 1000e6; // 1000 USDT

    function setUp() public {
        // Deploy contracts
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

        // Fund lending pool
        usdt.mint(address(lendingPool), 1000000e6); // 1M USDT

        // Setup borrower
        usdt.mint(borrower, 50000e6);
        vm.deal(borrower, 100 ether);

        // Setup lender
        usdt.mint(lender, 100000e6);
        vm.startPrank(lender);
        usdt.approve(address(lendingPool), 100000e6);
        lendingPool.deposit(100000e6);
        vm.stopPrank();
    }

    // ============ ETH Collateral Loan Tests ============

    function test_CreateLoanWithEth() public {
        uint256 ethCollateral = 1 ether; // ~$2000
        
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: ethCollateral}(
            LOAN_AMOUNT,
            InterestCalculator.LoanType.Personal,
            30 // 30 days
        );

        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(loan.borrower, borrower);
        assertEq(loan.amount, LOAN_AMOUNT);
        assertEq(loan.collateralAmount, ethCollateral);
        assertEq(uint256(loan.status), uint256(LoanManager.LoanStatus.Active));
        assertEq(loan.durationDays, 30);
    }

    function test_CreateLoanWithEth_CreditScoreRecorded() public {
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        (, uint256 totalLoans,,,,) = creditScore.getUserData(borrower);
        assertEq(totalLoans, 1);
    }

    function test_CreateLoanWithEth_BorrowerReceivesUSDT() public {
        uint256 balanceBefore = usdt.balanceOf(borrower);

        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        uint256 balanceAfter = usdt.balanceOf(borrower);
        assertEq(balanceAfter - balanceBefore, LOAN_AMOUNT);
    }

    function test_RevertCreateLoanWithEth_InsufficientCollateral() public {
        // New user needs 140% collateral for 500 score
        // $1000 loan needs $1400 collateral
        // 0.5 ETH = $1000, not enough

        vm.prank(borrower);
        vm.expectRevert(LoanManager.InsufficientCollateral.selector);
        loanManager.createLoanWithEth{value: 0.5 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);
    }

    function test_RevertCreateLoanWithEth_AmountTooSmall() public {
        vm.prank(borrower);
        vm.expectRevert(LoanManager.InvalidLoanAmount.selector);
        loanManager.createLoanWithEth{value: 1 ether}(50e6, InterestCalculator.LoanType.Personal, 30); // Below 100 USDT minimum
    }

    function test_RevertCreateLoanWithEth_DurationTooShort() public {
        vm.prank(borrower);
        vm.expectRevert(LoanManager.InvalidDuration.selector);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 5); // Below 7 days
    }

    function test_RevertCreateLoanWithEth_DurationTooLong() public {
        vm.prank(borrower);
        vm.expectRevert(LoanManager.InvalidDuration.selector);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 400); // Above 365 days
    }

    // ============ USDT Collateral Loan Tests ============

    function test_CreateLoanWithUsdt() public {
        uint256 usdtCollateral = 1500e6; // $1500 collateral for $1000 loan

        vm.startPrank(borrower);
        usdt.approve(address(loanManager), usdtCollateral);
        loanManager.createLoanWithUsdt(LOAN_AMOUNT, usdtCollateral, InterestCalculator.LoanType.Home, 60);
        vm.stopPrank();

        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(loan.borrower, borrower);
        assertEq(loan.amount, LOAN_AMOUNT);
        assertEq(loan.collateralAmount, usdtCollateral);
        assertEq(uint256(loan.collateralType), uint256(CollateralManager.CollateralType.USDT));
    }

    function test_RevertCreateLoanWithUsdt_InsufficientCollateral() public {
        uint256 insufficientCollateral = 1200e6; // Only 120%, need 140% for new user

        vm.startPrank(borrower);
        usdt.approve(address(loanManager), insufficientCollateral);
        vm.expectRevert(LoanManager.InsufficientCollateral.selector);
        loanManager.createLoanWithUsdt(LOAN_AMOUNT, insufficientCollateral, InterestCalculator.LoanType.Home, 60);
        vm.stopPrank();
    }

    // ============ Loan Repayment Tests ============

    function test_RepayLoan_Full() public {
        // Create loan
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        // Calculate total due
        uint256 totalDue = loanManager.getTotalDue(1);
        
        // Repay full amount
        vm.startPrank(borrower);
        usdt.approve(address(loanManager), totalDue);
        loanManager.repayLoan(1, totalDue);
        vm.stopPrank();

        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(uint256(loan.status), uint256(LoanManager.LoanStatus.Repaid));
        assertEq(loan.totalRepaid, totalDue);
    }

    function test_RepayLoan_CollateralReleased() public {
        uint256 ethCollateral = 1 ether;
        uint256 borrowerBalanceBefore = borrower.balance;

        // Create loan
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: ethCollateral}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        uint256 borrowerBalanceAfter = borrower.balance;
        
        // Repay
        uint256 totalDue = loanManager.getTotalDue(1);
        vm.startPrank(borrower);
        usdt.approve(address(loanManager), totalDue);
        loanManager.repayLoan(1, totalDue);
        vm.stopPrank();

        // Check collateral returned
        uint256 finalBalance = borrower.balance;
        assertEq(finalBalance, borrowerBalanceAfter + ethCollateral);
    }

    function test_RepayLoan_CreditScoreUpdated() public {
        // Create and repay loan
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        uint256 totalDue = loanManager.getTotalDue(1);
        vm.startPrank(borrower);
        usdt.approve(address(loanManager), totalDue);
        loanManager.repayLoan(1, totalDue);
        vm.stopPrank();

        (, uint256 totalLoans, uint256 completedLoans,,,) = creditScore.getUserData(borrower);
        assertEq(totalLoans, 1);
        assertEq(completedLoans, 1);
        
        uint256 score = creditScore.getScore(borrower);
        assertEq(score, 510); // 500 + 10 for repayment
    }

    function test_RepayLoan_Partial() public {
        // Create loan
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        uint256 totalDue = loanManager.getTotalDue(1);
        uint256 partialAmount = totalDue / 2;

        // Make partial repayment
        vm.startPrank(borrower);
        usdt.approve(address(loanManager), partialAmount);
        loanManager.repayLoan(1, partialAmount);
        vm.stopPrank();

        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(uint256(loan.status), uint256(LoanManager.LoanStatus.Active)); // Still active
        assertEq(loan.totalRepaid, partialAmount);
    }

    function test_RevertRepayLoan_NotBorrower() public {
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        address stranger = address(0x999);
        usdt.mint(stranger, 10000e6);

        vm.startPrank(stranger);
        usdt.approve(address(loanManager), 10000e6);
        vm.expectRevert(LoanManager.NotLoanBorrower.selector);
        loanManager.repayLoan(1, 1000e6);
        vm.stopPrank();
    }

    function test_RevertRepayLoan_InvalidLoanId() public {
        vm.prank(borrower);
        vm.expectRevert(LoanManager.InvalidLoanId.selector);
        loanManager.repayLoan(999, 1000e6);
    }

    // ============ Loan Default Tests ============

    function test_DefaultLoan() public {
        // Create loan with 30 day duration
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        // Fast forward past due date + grace period
        vm.warp(block.timestamp + 35 days);
        
        // Crash price to make loan liquidatable (1 ETH = $1000, loan = $1000 USDT + interest)
        priceFeed.setPrice(800e8);

        // Anyone can trigger default
        loanManager.defaultLoan(1);

        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(uint256(loan.status), uint256(LoanManager.LoanStatus.Defaulted));
    }

    function test_DefaultLoan_CreditScoreDecreased() public {
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        vm.warp(block.timestamp + 35 days);
        
        // Crash price to make loan liquidatable
        priceFeed.setPrice(800e8);
        
        loanManager.defaultLoan(1);

        uint256 score = creditScore.getScore(borrower);
        assertEq(score, 400); // 500 - 100 for default
    }

    function test_RevertDefaultLoan_NotDue() public {
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        // Try to default before due date
        vm.expectRevert(LoanManager.LoanNotDue.selector);
        loanManager.defaultLoan(1);
    }

    function test_RevertDefaultLoan_InGracePeriod() public {
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        // Fast forward to just after due date (still in grace period)
        vm.warp(block.timestamp + 31 days);

        vm.expectRevert(LoanManager.LoanNotDue.selector);
        loanManager.defaultLoan(1);
    }

    // ============ Multiple Loans Tests ============

    function test_MultipleLoansSameBorrower() public {
        vm.startPrank(borrower);
        
        // Create loan 1 with ETH
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);
        
        // Create loan 2 with USDT
        usdt.approve(address(loanManager), 1500e6);
        loanManager.createLoanWithUsdt(LOAN_AMOUNT, 1500e6, InterestCalculator.LoanType.Auto, 60);
        
        vm.stopPrank();

        uint256[] memory userLoanIds = loanManager.getUserLoans(borrower);
        assertEq(userLoanIds.length, 2);
        assertEq(userLoanIds[0], 1);
        assertEq(userLoanIds[1], 2);
    }

    function test_GetActiveLoanCount() public {
        vm.startPrank(borrower);
        
        // Create 3 loans
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);
        
        vm.stopPrank();

        assertEq(loanManager.getActiveLoanCount(borrower), 3);

        // Repay one loan
        uint256 totalDue = loanManager.getTotalDue(1);
        vm.startPrank(borrower);
        usdt.approve(address(loanManager), totalDue);
        loanManager.repayLoan(1, totalDue);
        vm.stopPrank();

        assertEq(loanManager.getActiveLoanCount(borrower), 2);
    }

    // ============ Loan Query Tests ============

    function test_GetOutstandingAmount() public {
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        uint256 outstanding = loanManager.getOutstandingAmount(1);
        uint256 totalDue = loanManager.getTotalDue(1);
        assertEq(outstanding, totalDue);

        // Make partial repayment
        uint256 partialAmount = totalDue / 3;
        vm.startPrank(borrower);
        usdt.approve(address(loanManager), partialAmount);
        loanManager.repayLoan(1, partialAmount);
        vm.stopPrank();

        outstanding = loanManager.getOutstandingAmount(1);
        assertEq(outstanding, totalDue - partialAmount);
    }

    function test_GetTotalDue() public {
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        uint256 totalDue = loanManager.getTotalDue(1);
        
        // Personal loan has 8% rate (800 basis points)
        uint256 expectedInterest = interestCalculator.calculateInterest(LOAN_AMOUNT, 800, 30);
        uint256 expectedTotal = LOAN_AMOUNT + expectedInterest;
        
        assertEq(totalDue, expectedTotal);
    }

    function test_IsOverdue() public {
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        assertFalse(loanManager.isOverdue(1));

        // Fast forward past due date
        vm.warp(block.timestamp + 31 days);

        assertTrue(loanManager.isOverdue(1));
    }

    // ============ Different Loan Types Tests ============

    function test_LoanTypes_DifferentRates() public {
        vm.startPrank(borrower);
        
        // Personal loan (8%)
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);
        
        // Home loan (5%)
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Home, 30);
        
        // Business loan (10%)
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Business, 30);
        
        // Auto loan (6%)
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Auto, 30);
        
        vm.stopPrank();

        uint256 totalDue1 = loanManager.getTotalDue(1);
        uint256 totalDue2 = loanManager.getTotalDue(2);
        uint256 totalDue3 = loanManager.getTotalDue(3);
        uint256 totalDue4 = loanManager.getTotalDue(4);

        // Business loan should have highest total due
        assertTrue(totalDue3 > totalDue1);
        assertTrue(totalDue3 > totalDue2);
        assertTrue(totalDue3 > totalDue4);

        // Home loan should have lowest total due
        assertTrue(totalDue2 < totalDue1);
        assertTrue(totalDue2 < totalDue3);
        assertTrue(totalDue2 < totalDue4);
    }

    // ============ Pause Tests ============

    function test_Pause() public {
        loanManager.pause();

        vm.prank(borrower);
        vm.expectRevert();
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);
    }

    function test_Unpause() public {
        loanManager.pause();
        loanManager.unpause();

        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);
    }

    // ============ Fuzz Tests ============

    function testFuzz_CreateLoan(uint256 loanAmount, uint8 durationDays) public {
        loanAmount = bound(loanAmount, 100e6, 5000e6); // 100-5000 USDT for new users
        durationDays = uint8(bound(durationDays, 7, 365));

        // Calculate required collateral (140% for new user)
        uint256 requiredCollateralUsd = (loanAmount * 140) / 100;
        uint256 ethCollateral = (requiredCollateralUsd * 1e20) / uint256(ETH_PRICE); // Convert USD to ETH

        vm.deal(borrower, ethCollateral + 1 ether);

        vm.prank(borrower);
        loanManager.createLoanWithEth{value: ethCollateral}(
            loanAmount,
            InterestCalculator.LoanType.Personal,
            durationDays
        );

        LoanManager.Loan memory loan = loanManager.getLoan(1);
        assertEq(loan.amount, loanAmount);
        assertEq(loan.durationDays, durationDays);
    }

    // ============ Protocol Fee Tests ============

    function test_ProtocolFeeCollection() public {
        // Lender deposits to pool first
        usdt.mint(lender, 10_000e6);
        vm.startPrank(lender);
        usdt.approve(address(lendingPool), 10_000e6);
        lendingPool.deposit(10_000e6);
        vm.stopPrank();

        // Create loan
        vm.deal(borrower, 1 ether);
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        // Get the loan to find actual interest rate used
        LoanManager.Loan memory loan = loanManager.getLoan(1);
        uint256 interest = interestCalculator.calculateInterest(loan.amount, loan.interestRate, loan.durationDays);
        uint256 expectedProtocolFee = (interest * 1000) / 10000; // 10% of interest
        uint256 expectedLenderInterest = interest - expectedProtocolFee;

        // Repay loan fully
        uint256 totalDue = loan.amount + interest;
        usdt.mint(borrower, totalDue);
        
        vm.startPrank(borrower);
        usdt.approve(address(loanManager), totalDue);
        loanManager.repayLoan(1, totalDue);
        vm.stopPrank();

        // Check protocol fee was collected
        (uint256 feePercentage, uint256 feesCollected, address treasury) = loanManager.getProtocolFeeInfo();
        assertEq(feePercentage, 1000, "Fee percentage should be 10%");
        assertEq(feesCollected, expectedProtocolFee, "Protocol fees should be collected");
        assertEq(treasury, address(this), "Treasury should be test contract");

        // Check lender received correct amount (90% of interest, allow 1 wei rounding error)
        uint256 lenderInterest = lendingPool.calculatePendingInterest(lender);
        assertApproxEqAbs(lenderInterest, expectedLenderInterest, 1, "Lender should receive 90% of interest");
    }

    function test_WithdrawProtocolFees() public {
        // Lender deposits to pool first
        usdt.mint(lender, 10_000e6);
        vm.startPrank(lender);
        usdt.approve(address(lendingPool), 10_000e6);
        lendingPool.deposit(10_000e6);
        vm.stopPrank();

        // Create and repay loan to generate fees
        vm.deal(borrower, 1 ether);
        vm.prank(borrower);
        loanManager.createLoanWithEth{value: 1 ether}(LOAN_AMOUNT, InterestCalculator.LoanType.Personal, 30);

        // Get the loan to find actual interest
        LoanManager.Loan memory loan = loanManager.getLoan(1);
        uint256 interest = interestCalculator.calculateInterest(loan.amount, loan.interestRate, loan.durationDays);
        uint256 expectedProtocolFee = (interest * 1000) / 10000;
        uint256 totalDue = loan.amount + interest;
        
        usdt.mint(borrower, totalDue);
        vm.startPrank(borrower);
        usdt.approve(address(loanManager), totalDue);
        loanManager.repayLoan(1, totalDue);
        vm.stopPrank();

        // Withdraw fees
        uint256 treasuryBalanceBefore = usdt.balanceOf(address(this));
        loanManager.withdrawProtocolFees();
        uint256 treasuryBalanceAfter = usdt.balanceOf(address(this));

        // Verify withdrawal
        assertEq(treasuryBalanceAfter - treasuryBalanceBefore, expectedProtocolFee, "Treasury should receive protocol fees");
        
        (, uint256 feesCollected,) = loanManager.getProtocolFeeInfo();
        assertEq(feesCollected, 0, "Fees should be reset after withdrawal");
    }

    function test_UpdateProtocolTreasury() public {
        address newTreasury = address(0x123);
        
        loanManager.updateProtocolTreasury(newTreasury);
        
        (,, address treasury) = loanManager.getProtocolFeeInfo();
        assertEq(treasury, newTreasury, "Treasury should be updated");
    }

    function test_RevertWithdrawProtocolFees_NoFees() public {
        vm.expectRevert(LoanManager.NoFeesToWithdraw.selector);
        loanManager.withdrawProtocolFees();
    }

    function test_RevertUpdateProtocolTreasury_ZeroAddress() public {
        vm.expectRevert(LoanManager.InvalidTreasuryAddress.selector);
        loanManager.updateProtocolTreasury(address(0));
    }

    receive() external payable {}
}

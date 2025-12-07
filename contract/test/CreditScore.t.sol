// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CreditScore} from "../src/CreditScore.sol";

contract CreditScoreTest is Test {
    CreditScore public creditScore;

    address public owner = address(this);
    address public loanManager = address(0x1);
    address public borrower1 = address(0x2);
    address public borrower2 = address(0x3);

    event ScoreUpdated(address indexed user, uint256 oldScore, uint256 newScore, string reason);
    event LoanRecorded(address indexed user, uint256 loanAmount);
    event RepaymentRecorded(address indexed user, uint256 repaymentAmount);
    event DefaultRecorded(address indexed user, uint256 loanAmount);

    function setUp() public {
        creditScore = new CreditScore();
        creditScore.setLoanManager(loanManager);
    }

    // ============ Initialization Tests ============

    function test_InitialSetup() public view {
        assertEq(creditScore.owner(), owner);
        assertEq(creditScore.loanManager(), loanManager);
        assertEq(creditScore.INITIAL_SCORE(), 500);
        assertEq(creditScore.MAX_SCORE(), 1000);
    }

    function test_SetLoanManager() public {
        address newManager = address(0x4);
        creditScore.setLoanManager(newManager);
        assertEq(creditScore.loanManager(), newManager);
    }

    function test_RevertSetLoanManager_ZeroAddress() public {
        vm.expectRevert(CreditScore.InvalidAddress.selector);
        creditScore.setLoanManager(address(0));
    }

    // ============ Initial Score Tests ============

    function test_GetScore_NewUser() public view {
        uint256 score = creditScore.getScore(borrower1);
        assertEq(score, 500); // Initial score
    }

    function test_GetUserData_NewUser() public view {
        (uint256 score, uint256 totalLoans, uint256 completedLoans, uint256 defaultedLoans, uint256 totalRepaid, uint256 successRate) =
            creditScore.getUserData(borrower1);

        assertEq(score, 500);
        assertEq(totalLoans, 0);
        assertEq(completedLoans, 0);
        assertEq(defaultedLoans, 0);
        assertEq(totalRepaid, 0);
        assertEq(successRate, 0);
    }

    // ============ Record Loan Tests ============

    function test_RecordLoan() public {
        uint256 loanAmount = 1000e6;

        vm.prank(loanManager);
        vm.expectEmit(true, false, false, true);
        emit LoanRecorded(borrower1, loanAmount);
        creditScore.recordLoan(borrower1, loanAmount);

        (uint256 score, uint256 totalLoans,,,,) = creditScore.getUserData(borrower1);
        assertEq(score, 500); // Score doesn't change on loan creation
        assertEq(totalLoans, 1);
    }

    function test_RecordMultipleLoans() public {
        vm.startPrank(loanManager);
        creditScore.recordLoan(borrower1, 1000e6);
        creditScore.recordLoan(borrower1, 2000e6);
        creditScore.recordLoan(borrower1, 3000e6);
        vm.stopPrank();

        (, uint256 totalLoans,,,,) = creditScore.getUserData(borrower1);
        assertEq(totalLoans, 3);
    }

    function test_RevertRecordLoan_NotLoanManager() public {
        vm.prank(borrower1);
        vm.expectRevert(CreditScore.OnlyLoanManager.selector);
        creditScore.recordLoan(borrower1, 1000e6);
    }

    // ============ Record Repayment Tests ============

    function test_RecordRepayment() public {
        uint256 loanAmount = 1000e6;
        uint256 repaymentAmount = 1100e6;

        vm.startPrank(loanManager);
        creditScore.recordLoan(borrower1, loanAmount);
        
        vm.expectEmit(true, false, false, true);
        emit RepaymentRecorded(borrower1, repaymentAmount);
        creditScore.recordRepayment(borrower1, repaymentAmount);
        vm.stopPrank();

        (uint256 score, uint256 totalLoans, uint256 completedLoans,, uint256 totalRepaid,) =
            creditScore.getUserData(borrower1);

        assertEq(score, 510); // Initial 500 + 10 for repayment
        assertEq(totalLoans, 1);
        assertEq(completedLoans, 1);
        assertEq(totalRepaid, repaymentAmount);
    }

    function test_RecordRepayment_BonusScore() public {
        vm.startPrank(loanManager);
        
        // Complete 5 loans (should trigger bonus)
        for (uint256 i = 0; i < 5; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            creditScore.recordRepayment(borrower1, 1100e6);
        }
        
        vm.stopPrank();

        (uint256 score,, uint256 completedLoans,,,) = creditScore.getUserData(borrower1);
        
        assertEq(completedLoans, 5);
        // Score = 500 + (4 * 10) + (10 + 50 bonus for 5th) = 600
        assertEq(score, 600);
    }

    function test_RecordRepayment_MaxScore() public {
        vm.startPrank(loanManager);
        
        // Complete enough loans to reach max score
        for (uint256 i = 0; i < 60; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            creditScore.recordRepayment(borrower1, 1100e6);
        }
        
        vm.stopPrank();

        uint256 score = creditScore.getScore(borrower1);
        assertEq(score, 1000); // Max score
    }

    // ============ Record Default Tests ============

    function test_RecordDefault() public {
        uint256 loanAmount = 1000e6;

        vm.startPrank(loanManager);
        creditScore.recordLoan(borrower1, loanAmount);
        
        vm.expectEmit(true, false, false, true);
        emit DefaultRecorded(borrower1, loanAmount);
        creditScore.recordDefault(borrower1, loanAmount);
        vm.stopPrank();

        (uint256 score,,, uint256 defaultedLoans,,) = creditScore.getUserData(borrower1);
        
        assertEq(score, 400); // 500 - 100 for default
        assertEq(defaultedLoans, 1);
    }

    function test_RecordDefault_MinScore() public {
        vm.startPrank(loanManager);
        
        // Default multiple times to reach min score
        for (uint256 i = 0; i < 10; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            creditScore.recordDefault(borrower1, 1000e6);
        }
        
        vm.stopPrank();

        uint256 score = creditScore.getScore(borrower1);
        assertEq(score, 0); // Min score
    }

    // ============ Collateral Ratio Tests ============

    function test_GetRequiredCollateralRatio_Excellent() public {
        // Build score to excellent (800+)
        vm.startPrank(loanManager);
        for (uint256 i = 0; i < 35; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            creditScore.recordRepayment(borrower1, 1100e6);
        }
        vm.stopPrank();

        uint256 score = creditScore.getScore(borrower1);
        assertTrue(score >= 800);

        uint256 ratio = creditScore.getRequiredCollateralRatio(borrower1);
        assertEq(ratio, 110); // Excellent tier
    }

    function test_GetRequiredCollateralRatio_Good() public {
        // Build score to good (600-799)
        vm.startPrank(loanManager);
        for (uint256 i = 0; i < 14; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            creditScore.recordRepayment(borrower1, 1100e6);
        }
        vm.stopPrank();

        uint256 score = creditScore.getScore(borrower1);
        assertTrue(score >= 600 && score < 800);

        uint256 ratio = creditScore.getRequiredCollateralRatio(borrower1);
        assertEq(ratio, 120); // Good tier
    }

    function test_GetRequiredCollateralRatio_Fair() public {
        // New user has 500 score (Fair tier)
        uint256 ratio = creditScore.getRequiredCollateralRatio(borrower1);
        assertEq(ratio, 140); // Fair tier (400-599)
    }

    function test_GetRequiredCollateralRatio_Poor() public {
        // One default brings to 400 (Poor tier)
        vm.startPrank(loanManager);
        creditScore.recordLoan(borrower1, 1000e6);
        creditScore.recordDefault(borrower1, 1000e6);
        vm.stopPrank();

        uint256 score = creditScore.getScore(borrower1);
        assertEq(score, 400);

        uint256 ratio = creditScore.getRequiredCollateralRatio(borrower1);
        assertEq(ratio, 140); // Fair tier (exactly 400)
    }

    function test_GetRequiredCollateralRatio_VeryPoor() public {
        // Multiple defaults bring below 200
        vm.startPrank(loanManager);
        creditScore.recordLoan(borrower1, 1000e6);
        creditScore.recordDefault(borrower1, 1000e6);
        creditScore.recordLoan(borrower1, 1000e6);
        creditScore.recordDefault(borrower1, 1000e6);
        creditScore.recordLoan(borrower1, 1000e6);
        creditScore.recordDefault(borrower1, 1000e6);
        creditScore.recordLoan(borrower1, 1000e6);
        creditScore.recordDefault(borrower1, 1000e6);
        vm.stopPrank();

        uint256 score = creditScore.getScore(borrower1);
        assertTrue(score < 200);

        uint256 ratio = creditScore.getRequiredCollateralRatio(borrower1);
        assertEq(ratio, 180); // Very Poor tier
    }

    // ============ Credit Tier Tests ============

    function test_GetCreditTier() public {
        string memory tier = creditScore.getCreditTier(borrower1);
        assertEq(tier, "Fair"); // New user at 500

        // Build to Excellent
        vm.startPrank(loanManager);
        for (uint256 i = 0; i < 35; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            creditScore.recordRepayment(borrower1, 1100e6);
        }
        vm.stopPrank();

        tier = creditScore.getCreditTier(borrower1);
        assertEq(tier, "Excellent");
    }

    // ============ Loan Qualification Tests ============

    function test_QualifiesForLoan_NewUser() public view {
        // New users can borrow up to 5000 USDT
        assertTrue(creditScore.qualifiesForLoan(borrower1, 5000e6));
        assertFalse(creditScore.qualifiesForLoan(borrower1, 5001e6));
    }

    function test_QualifiesForLoan_ExcellentScore() public {
        // Build to excellent score
        vm.startPrank(loanManager);
        for (uint256 i = 0; i < 35; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            creditScore.recordRepayment(borrower1, 1100e6);
        }
        vm.stopPrank();

        // Excellent users can borrow up to 100k USDT
        assertTrue(creditScore.qualifiesForLoan(borrower1, 100000e6));
        assertFalse(creditScore.qualifiesForLoan(borrower1, 100001e6));
    }

    function test_QualifiesForLoan_WithDefaults() public {
        vm.startPrank(loanManager);
        
        // Take 5 loans, default 2 (40% default rate)
        for (uint256 i = 0; i < 5; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            if (i < 2) {
                creditScore.recordDefault(borrower1, 1000e6);
            } else {
                creditScore.recordRepayment(borrower1, 1100e6);
            }
        }
        
        vm.stopPrank();

        // Over 20% default rate disqualifies
        assertFalse(creditScore.qualifiesForLoan(borrower1, 1000e6));
    }

    function test_QualifiesForLoan_AcceptableDefaults() public {
        vm.startPrank(loanManager);
        
        // Take 10 loans, default 1 (10% default rate - acceptable)
        for (uint256 i = 0; i < 10; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            if (i == 0) {
                creditScore.recordDefault(borrower1, 1000e6);
            } else {
                creditScore.recordRepayment(borrower1, 1100e6);
            }
        }
        
        vm.stopPrank();

        // 10% default rate is acceptable, check if qualifies based on score
        uint256 score = creditScore.getScore(borrower1);
        // Score should be around 500 - 100 + (9 * 10) + bonus = 490
        
        // Should qualify for amounts up to their tier limit
        assertTrue(creditScore.qualifiesForLoan(borrower1, 5000e6));
    }

    // ============ Success Rate Tests ============

    function test_SuccessRate() public {
        vm.startPrank(loanManager);
        
        // 8 successful, 2 defaults = 80% success rate
        for (uint256 i = 0; i < 10; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            if (i < 8) {
                creditScore.recordRepayment(borrower1, 1100e6);
            } else {
                creditScore.recordDefault(borrower1, 1000e6);
            }
        }
        
        vm.stopPrank();

        (,,,,,uint256 successRate) = creditScore.getUserData(borrower1);
        assertEq(successRate, 80);
    }

    // ============ Multiple Users Tests ============

    function test_MultipleUsers() public {
        vm.startPrank(loanManager);
        
        // Borrower 1: Good repayment
        creditScore.recordLoan(borrower1, 1000e6);
        creditScore.recordRepayment(borrower1, 1100e6);
        
        // Borrower 2: Default
        creditScore.recordLoan(borrower2, 2000e6);
        creditScore.recordDefault(borrower2, 2000e6);
        
        vm.stopPrank();

        uint256 score1 = creditScore.getScore(borrower1);
        uint256 score2 = creditScore.getScore(borrower2);

        assertEq(score1, 510); // 500 + 10
        assertEq(score2, 400); // 500 - 100
    }

    // ============ Fuzz Tests ============

    function testFuzz_RecordLoans(uint8 numLoans) public {
        numLoans = uint8(bound(numLoans, 1, 50));

        vm.startPrank(loanManager);
        for (uint256 i = 0; i < numLoans; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
        }
        vm.stopPrank();

        (, uint256 totalLoans,,,,) = creditScore.getUserData(borrower1);
        assertEq(totalLoans, numLoans);
    }

    function testFuzz_RecordRepayments(uint8 numRepayments) public {
        numRepayments = uint8(bound(numRepayments, 1, 100));

        vm.startPrank(loanManager);
        for (uint256 i = 0; i < numRepayments; i++) {
            creditScore.recordLoan(borrower1, 1000e6);
            creditScore.recordRepayment(borrower1, 1100e6);
        }
        vm.stopPrank();

        uint256 score = creditScore.getScore(borrower1);
        assertTrue(score >= 500); // Score should increase or stay at max
        assertTrue(score <= 1000); // Should not exceed max
    }
}

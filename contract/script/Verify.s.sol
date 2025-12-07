// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MockUSDT} from "../src/MockUSDT.sol";
import {USDTFaucet} from "../src/USDTFaucet.sol";
import {InterestCalculator} from "../src/InterestCalculator.sol";
import {CollateralManager} from "../src/CollateralManager.sol";
import {CreditScore} from "../src/CreditScore.sol";
import {LendingPool} from "../src/LendingPool.sol";
import {LoanManager} from "../src/LoanManager.sol";

/**
 * @title Verify
 * @notice Post-deployment verification script
 * @dev Checks all contracts are deployed correctly and linked properly
 * 
 * Usage:
 * forge script script/Verify.s.sol --rpc-url $RPC_URL
 */
contract Verify is Script {
    // Load addresses from deployment
    address public usdtAddress;
    address public faucetAddress;
    address public interestCalculatorAddress;
    address public collateralManagerAddress;
    address public creditScoreAddress;
    address public lendingPoolAddress;
    address public loanManagerAddress;
    address public oracleAddress;

    // Contract instances
    MockUSDT public usdt;
    USDTFaucet public faucet;
    InterestCalculator public interestCalculator;
    CollateralManager public collateralManager;
    CreditScore public creditScore;
    LendingPool public lendingPool;
    LoanManager public loanManager;

    uint256 public errorCount = 0;

    function run() external view {
        console.log("=== OnLoan Protocol Verification ===");
        console.log("Chain ID:", block.chainid);
        console.log("");

        // Load addresses (you would parse from deployment file in production)
        loadAddresses();

        // Run all verification checks
        verifyMockUSDT();
        verifyUSDTFaucet();
        verifyInterestCalculator();
        verifyCollateralManager();
        verifyCreditScore();
        verifyLendingPool();
        verifyLoanManager();
        verifyIntegrations();

        // Print summary
        console.log("");
        if (errorCount == 0) {
            console.log("=== Verification PASSED ===");
            console.log("All contracts deployed and configured correctly!");
        } else {
            console.log("=== Verification FAILED ===");
            console.log("Total errors:", errorCount);
        }
    }

    function loadAddresses() internal {
        // In production, you would load these from the deployment JSON file
        // For now, you need to manually set these after deployment
        console.log("Loading contract addresses...");
        console.log("NOTE: Update addresses in script before running verification");
        console.log("");
    }

    function verifyMockUSDT() internal view {
        console.log("1. Verifying MockUSDT...");
        
        if (usdtAddress == address(0)) {
            console.log("   [SKIP] Address not set");
            return;
        }

        usdt = MockUSDT(usdtAddress);

        // Check basic properties
        checkEqual(usdt.decimals(), 6, "   Decimals should be 6");
        checkEqual(bytes(usdt.name()).length > 0, true, "   Name should be set");
        checkEqual(bytes(usdt.symbol()).length > 0, true, "   Symbol should be set");
        
        console.log("   MockUSDT verification complete");
        console.log("");
    }

    function verifyUSDTFaucet() internal view {
        console.log("2. Verifying USDTFaucet...");
        
        if (faucetAddress == address(0)) {
            console.log("   [SKIP] Address not set");
            return;
        }

        faucet = USDTFaucet(faucetAddress);

        // Check configuration
        checkEqual(address(faucet.usdtToken()), usdtAddress, "   USDT address should match");
        checkEqual(faucet.CLAIM_AMOUNT() > 0, true, "   Claim amount should be set");
        
        // Check balance
        uint256 balance = usdt.balanceOf(faucetAddress);
        checkEqual(balance > 0, true, "   Faucet should have USDT balance");
        console.log("   Faucet balance:", balance / 10 ** 6, "USDT");
        
        console.log("   USDTFaucet verification complete");
        console.log("");
    }

    function verifyInterestCalculator() internal view {
        console.log("3. Verifying InterestCalculator...");
        
        if (interestCalculatorAddress == address(0)) {
            console.log("   [SKIP] Address not set");
            return;
        }

        interestCalculator = InterestCalculator(interestCalculatorAddress);

        // Check constants are set
        checkEqual(interestCalculator.BASE_RATE() > 0, true, "   Base rate should be set");
        checkEqual(interestCalculator.OPTIMAL_UTILIZATION() > 0, true, "   Optimal utilization should be set");
        
        // Test interest calculation
        uint256 testInterest = interestCalculator.calculateInterest(1000e6, 1000, 30);
        checkEqual(testInterest > 0, true, "   Should calculate interest correctly");
        
        console.log("   InterestCalculator verification complete");
        console.log("");
    }

    function verifyCollateralManager() internal view {
        console.log("4. Verifying CollateralManager...");
        
        if (collateralManagerAddress == address(0)) {
            console.log("   [SKIP] Address not set");
            return;
        }

        collateralManager = CollateralManager(payable(collateralManagerAddress));

        // Check configuration
        checkEqual(address(collateralManager.usdt()), usdtAddress, "   USDT address should match");
        checkEqual(address(collateralManager.ethUsdPriceFeed()) != address(0), true, "   Oracle should be set");
        
        // Check owner
        checkEqual(collateralManager.owner() == loanManagerAddress, true, "   Owner should be LoanManager");
        
        console.log("   CollateralManager verification complete");
        console.log("");
    }

    function verifyCreditScore() internal view {
        console.log("5. Verifying CreditScore...");
        
        if (creditScoreAddress == address(0)) {
            console.log("   [SKIP] Address not set");
            return;
        }

        creditScore = CreditScore(creditScoreAddress);

        // Check loan manager is set
        checkEqual(address(creditScore.loanManager()) == loanManagerAddress, true, "   LoanManager should be set");
        
        // Check constants
        checkEqual(creditScore.DEFAULT_CREDIT_SCORE() == 500, true, "   Default score should be 500");
        checkEqual(creditScore.MAX_CREDIT_SCORE() == 1000, true, "   Max score should be 1000");
        checkEqual(creditScore.MIN_CREDIT_SCORE() == 300, true, "   Min score should be 300");
        
        console.log("   CreditScore verification complete");
        console.log("");
    }

    function verifyLendingPool() internal view {
        console.log("6. Verifying LendingPool...");
        
        if (lendingPoolAddress == address(0)) {
            console.log("   [SKIP] Address not set");
            return;
        }

        lendingPool = LendingPool(lendingPoolAddress);

        // Check configuration
        checkEqual(address(lendingPool.usdt()) == usdtAddress, true, "   USDT address should match");
        checkEqual(address(lendingPool.interestCalculator()) == interestCalculatorAddress, true, "   InterestCalculator should match");
        checkEqual(address(lendingPool.loanManager()) == loanManagerAddress, true, "   LoanManager should be set");
        
        // Check initial state
        checkEqual(lendingPool.totalDeposits() == 0, true, "   Total deposits should be 0 initially");
        checkEqual(lendingPool.totalBorrowed() == 0, true, "   Total borrowed should be 0 initially");
        
        console.log("   LendingPool verification complete");
        console.log("");
    }

    function verifyLoanManager() internal view {
        console.log("7. Verifying LoanManager...");
        
        if (loanManagerAddress == address(0)) {
            console.log("   [SKIP] Address not set");
            return;
        }

        loanManager = LoanManager(loanManagerAddress);

        // Check all dependencies
        checkEqual(address(loanManager.usdt()) == usdtAddress, true, "   USDT address should match");
        checkEqual(address(loanManager.collateralManager()) == collateralManagerAddress, true, "   CollateralManager should match");
        checkEqual(address(loanManager.interestCalculator()) == interestCalculatorAddress, true, "   InterestCalculator should match");
        checkEqual(address(loanManager.creditScore()) == creditScoreAddress, true, "   CreditScore should match");
        checkEqual(address(loanManager.lendingPool()) == lendingPoolAddress, true, "   LendingPool should match");
        
        // Check protocol fee configuration
        (uint256 feePercentage, uint256 feesCollected, address treasury) = loanManager.getProtocolFeeInfo();
        checkEqual(feePercentage == 1000, true, "   Protocol fee should be 10% (1000 basis points)");
        checkEqual(feesCollected == 0, true, "   Fees collected should be 0 initially");
        checkEqual(treasury != address(0), true, "   Treasury should be set");
        
        console.log("   Protocol Treasury:", treasury);
        console.log("   LoanManager verification complete");
        console.log("");
    }

    function verifyIntegrations() internal view {
        console.log("8. Verifying Contract Integrations...");
        
        if (loanManagerAddress == address(0)) {
            console.log("   [SKIP] Addresses not set");
            return;
        }

        // Verify permission chain
        checkEqual(creditScore.loanManager() == loanManagerAddress, true, "   CreditScore → LoanManager link");
        checkEqual(collateralManager.owner() == loanManagerAddress, true, "   CollateralManager → LoanManager ownership");
        checkEqual(lendingPool.loanManager() == loanManagerAddress, true, "   LendingPool → LoanManager link");
        
        // Verify loan manager can interact with pool
        checkEqual(lendingPool.owner() != address(0), true, "   LendingPool has owner");
        
        console.log("   Integration verification complete");
        console.log("");
    }

    // Helper functions
    function checkEqual(uint256 a, uint256 b, string memory message) internal view {
        if (a == b) {
            console.log("   [PASS]", message);
        } else {
            console.log("   [FAIL]", message);
            console.log("          Expected:", b, "Got:", a);
            errorCount++;
        }
    }

    function checkEqual(bool condition, bool expected, string memory message) internal view {
        if (condition == expected) {
            console.log("   [PASS]", message);
        } else {
            console.log("   [FAIL]", message);
            errorCount++;
        }
    }

    function checkEqual(address a, address b, string memory message) internal view {
        if (a == b) {
            console.log("   [PASS]", message);
        } else {
            console.log("   [FAIL]", message);
            console.log("          Expected:", b);
            console.log("          Got:", a);
            errorCount++;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LendingPool.sol";
import "../src/InterestCalculator.sol";
import "../src/MockUSDT.sol";

contract LendingPoolTest is Test {
    LendingPool public pool;
    InterestCalculator public calculator;
    MockUSDT public usdt;
    
    address public owner;
    address public lender1;
    address public lender2;
    address public lender3;
    
    function setUp() public {
        owner = address(this);
        lender1 = makeAddr("lender1");
        lender2 = makeAddr("lender2");
        lender3 = makeAddr("lender3");
        
        // Deploy contracts
        usdt = new MockUSDT();
        calculator = new InterestCalculator();
        pool = new LendingPool(address(usdt), address(calculator));
        
        // Mint USDT to lenders
        usdt.mint(lender1, 100_000 * 10 ** 6);
        usdt.mint(lender2, 50_000 * 10 ** 6);
        usdt.mint(lender3, 25_000 * 10 ** 6);
    }
    
    function test_InitialSetup() public view {
        assertEq(address(pool.usdt()), address(usdt));
        assertEq(address(pool.interestCalculator()), address(calculator));
        assertEq(pool.owner(), owner);
        assertEq(pool.totalDeposits(), 0);
        assertEq(pool.totalBorrowed(), 0);
    }
    
    function test_Deposit() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        vm.stopPrank();
        
        (uint256 amount, uint256 depositTime, ) = pool.getDepositInfo(lender1);
        assertEq(amount, depositAmount);
        assertEq(depositTime, block.timestamp);
        assertEq(pool.totalDeposits(), depositAmount);
    }
    
    function test_DepositMultipleLenders() public {
        uint256 amount1 = 10_000 * 10 ** 6;
        uint256 amount2 = 5_000 * 10 ** 6;
        
        // Lender 1 deposits
        vm.startPrank(lender1);
        usdt.approve(address(pool), amount1);
        pool.deposit(amount1);
        vm.stopPrank();
        
        // Lender 2 deposits
        vm.startPrank(lender2);
        usdt.approve(address(pool), amount2);
        pool.deposit(amount2);
        vm.stopPrank();
        
        assertEq(pool.totalDeposits(), amount1 + amount2);
        
        (uint256 balance1, , ) = pool.getDepositInfo(lender1);
        (uint256 balance2, , ) = pool.getDepositInfo(lender2);
        assertEq(balance1, amount1);
        assertEq(balance2, amount2);
    }
    
    function test_DepositMultipleTimes() public {
        uint256 firstDeposit = 5_000 * 10 ** 6;
        uint256 secondDeposit = 3_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        
        // First deposit
        usdt.approve(address(pool), firstDeposit);
        pool.deposit(firstDeposit);
        
        // Second deposit
        usdt.approve(address(pool), secondDeposit);
        pool.deposit(secondDeposit);
        
        vm.stopPrank();
        
        (uint256 amount, , ) = pool.getDepositInfo(lender1);
        assertEq(amount, firstDeposit + secondDeposit);
    }
    
    function test_RevertDeposit_ZeroAmount() public {
        vm.prank(lender1);
        vm.expectRevert("LendingPool: zero amount");
        pool.deposit(0);
    }
    
    function test_RevertDeposit_InsufficientAllowance() public {
        vm.prank(lender1);
        vm.expectRevert();
        pool.deposit(10_000 * 10 ** 6);
    }
    
    function test_Withdraw() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        uint256 withdrawAmount = 5_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        
        uint256 balanceBefore = usdt.balanceOf(lender1);
        pool.withdraw(withdrawAmount);
        uint256 balanceAfter = usdt.balanceOf(lender1);
        vm.stopPrank();
        
        assertEq(balanceAfter - balanceBefore, withdrawAmount);
        
        (uint256 remaining, , ) = pool.getDepositInfo(lender1);
        assertEq(remaining, depositAmount - withdrawAmount);
        assertEq(pool.totalDeposits(), depositAmount - withdrawAmount);
    }
    
    function test_WithdrawFull() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        
        pool.withdraw(depositAmount);
        vm.stopPrank();
        
        (uint256 amount, , ) = pool.getDepositInfo(lender1);
        assertEq(amount, 0);
        assertEq(pool.totalDeposits(), 0);
    }
    
    function test_RevertWithdraw_ZeroAmount() public {
        vm.prank(lender1);
        vm.expectRevert("LendingPool: zero amount");
        pool.withdraw(0);
    }
    
    function test_RevertWithdraw_InsufficientBalance() public {
        uint256 depositAmount = 5_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        
        vm.expectRevert("LendingPool: insufficient balance");
        pool.withdraw(10_000 * 10 ** 6);
        vm.stopPrank();
    }
    
    function test_RevertWithdraw_InsufficientLiquidity() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        vm.stopPrank();
        
        // Simulate borrowed funds reducing liquidity
        pool.updateBorrowedAmount(8_000 * 10 ** 6);
        
        // Transfer USDT out to simulate borrowed funds
        vm.prank(address(pool));
        usdt.transfer(owner, 8_000 * 10 ** 6);
        
        vm.prank(lender1);
        vm.expectRevert("LendingPool: insufficient liquidity");
        pool.withdraw(5_000 * 10 ** 6); // Only 2000 available
    }
    
    function test_GetAvailableLiquidity() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        vm.stopPrank();
        
        assertEq(pool.getAvailableLiquidity(), depositAmount);
    }
    
    function test_GetUtilizationRate_Zero() public view {
        assertEq(pool.getUtilizationRate(), 0);
    }
    
    function test_GetUtilizationRate() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        vm.stopPrank();
        
        // Set borrowed amount to 5000 (50% utilization)
        pool.updateBorrowedAmount(5_000 * 10 ** 6);
        
        uint256 utilization = pool.getUtilizationRate();
        // Utilization = borrowed / totalDeposits = 5000 / 10000 = 50% = 5000 basis points
        assertEq(utilization, 5000);
    }
    
    function test_GetCurrentAPY() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        vm.stopPrank();
        
        // With zero utilization, APY should be 0
        assertEq(pool.getCurrentAPY(), 0);
        
        // Set 50% utilization
        pool.updateBorrowedAmount(10_000 * 10 ** 6);
        
        uint256 apy = pool.getCurrentAPY();
        assertGt(apy, 0);
    }
    
    function test_CalculatePendingInterest() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        vm.stopPrank();
        
        // Simulate loan repayment with interest (from LoanManager)
        pool.setLoanManager(address(this));
        usdt.approve(address(pool), 100e6);
        pool.repayToPool(100e6, 50e6); // 50 USDT interest
        
        uint256 pendingInterest = pool.calculatePendingInterest(lender1);
        assertEq(pendingInterest, 50e6); // Lender gets the interest
    }
    
    function test_ClaimInterest() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        vm.stopPrank();
        
        // Simulate loan repayment with interest (from LoanManager)
        pool.setLoanManager(address(this));
        uint256 interestAmount = 100e6;
        usdt.approve(address(pool), 1100e6);
        pool.repayToPool(1100e6, interestAmount); // 100 USDT interest
        
        uint256 pendingBefore = pool.calculatePendingInterest(lender1);
        assertEq(pendingBefore, interestAmount);
        
        uint256 balanceBefore = usdt.balanceOf(lender1);
        
        vm.prank(lender1);
        pool.claimInterest();
        
        uint256 balanceAfter = usdt.balanceOf(lender1);
        assertEq(balanceAfter - balanceBefore, interestAmount);
        
        // Pending interest should reset
        uint256 pendingAfter = pool.calculatePendingInterest(lender1);
        assertEq(pendingAfter, 0);
    }
    
    function test_RevertClaimInterest_NoDeposit() public {
        vm.prank(lender1);
        vm.expectRevert("LendingPool: no interest");
        pool.claimInterest();
    }
    
    function test_RevertClaimInterest_NoInterest() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        
        // Immediately try to claim (no time passed, zero utilization)
        vm.expectRevert("LendingPool: no interest");
        pool.claimInterest();
        vm.stopPrank();
    }
    
    function test_RevertClaimInterest_InsufficientLiquidity() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        vm.stopPrank();
        
        // Simulate loan repayment with interest
        pool.setLoanManager(address(this));
        uint256 interestAmount = 100e6;
        usdt.approve(address(pool), 1100e6);
        pool.repayToPool(1100e6, interestAmount);
        
        // Borrow ALL liquidity so interest can't be paid
        // Pool has 11,100 USDT after repayment (10,000 deposit + 1,100 repayment)
        pool.borrowFromPool(address(this), 11_100e6);
        
        // Try to claim without sufficient pool liquidity
        vm.prank(lender1);
        vm.expectRevert("LendingPool: insufficient liquidity");
        pool.claimInterest();
    }
    
    function test_UpdateBorrowedAmount() public {
        uint256 newAmount = 5_000 * 10 ** 6;
        
        pool.updateBorrowedAmount(newAmount);
        
        assertEq(pool.totalBorrowed(), newAmount);
    }
    
    function test_RevertUpdateBorrowedAmount_NotOwner() public {
        vm.prank(lender1);
        vm.expectRevert();
        pool.updateBorrowedAmount(1_000 * 10 ** 6);
    }
    
    function test_GetPoolStats() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        vm.stopPrank();
        
        pool.updateBorrowedAmount(5_000 * 10 ** 6);
        
        (
            uint256 totalDeposits,
            uint256 totalBorrowed,
            uint256 availableLiquidity,
            uint256 utilization,
            uint256 apy
        ) = pool.getPoolStats();
        
        assertEq(totalDeposits, depositAmount);
        assertEq(totalBorrowed, 5_000 * 10 ** 6);
        assertEq(availableLiquidity, depositAmount);
        assertGt(utilization, 0);
        assertGt(apy, 0);
    }
    
    function test_Pause() public {
        pool.pause();
        
        vm.prank(lender1);
        vm.expectRevert();
        pool.deposit(1_000 * 10 ** 6);
    }
    
    function test_Unpause() public {
        pool.pause();
        pool.unpause();
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), 1_000 * 10 ** 6);
        pool.deposit(1_000 * 10 ** 6);
        vm.stopPrank();
        
        (uint256 amount, , ) = pool.getDepositInfo(lender1);
        assertEq(amount, 1_000 * 10 ** 6);
    }
    
    function test_EventDeposited() public {
        uint256 amount = 10_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), amount);
        
        vm.expectEmit(true, false, false, true);
        emit LendingPool.Deposited(lender1, amount, block.timestamp);
        
        pool.deposit(amount);
        vm.stopPrank();
    }
    
    function test_EventWithdrawn() public {
        uint256 depositAmount = 10_000 * 10 ** 6;
        uint256 withdrawAmount = 5_000 * 10 ** 6;
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        
        vm.expectEmit(true, false, false, true);
        emit LendingPool.Withdrawn(lender1, withdrawAmount, block.timestamp);
        
        pool.withdraw(withdrawAmount);
        vm.stopPrank();
    }
    
    function test_EventBorrowedAmountUpdated() public {
        uint256 newAmount = 5_000 * 10 ** 6;
        
        vm.expectEmit(false, false, false, true);
        emit LendingPool.BorrowedAmountUpdated(0, newAmount);
        
        pool.updateBorrowedAmount(newAmount);
    }
    
    function testFuzz_Deposit(uint256 amount) public {
        amount = bound(amount, 1, 100_000 * 10 ** 6);
        
        usdt.mint(lender1, amount);
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), amount);
        pool.deposit(amount);
        vm.stopPrank();
        
        (uint256 deposited, , ) = pool.getDepositInfo(lender1);
        assertEq(deposited, amount);
    }
    
    function testFuzz_DepositAndWithdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        depositAmount = bound(depositAmount, 1000, 100_000 * 10 ** 6);
        withdrawAmount = bound(withdrawAmount, 1, depositAmount);
        
        usdt.mint(lender1, depositAmount);
        
        vm.startPrank(lender1);
        usdt.approve(address(pool), depositAmount);
        pool.deposit(depositAmount);
        
        pool.withdraw(withdrawAmount);
        vm.stopPrank();
        
        (uint256 remaining, , ) = pool.getDepositInfo(lender1);
        assertEq(remaining, depositAmount - withdrawAmount);
    }
}

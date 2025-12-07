// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CollateralManager} from "../src/CollateralManager.sol";
import {MockUSDT} from "../src/MockUSDT.sol";
import {MockPriceFeed} from "./mocks/MockPriceFeed.sol";

contract CollateralManagerTest is Test {
    CollateralManager public collateralManager;
    MockUSDT public usdt;
    MockPriceFeed public priceFeed;

    address public owner = address(this);
    address public borrower = address(0x1);
    address public liquidator = address(0x2);

    uint256 public constant INITIAL_ETH_PRICE = 2000e8; // $2000 with 8 decimals
    uint256 public constant LOAN_AMOUNT = 1000e6; // 1000 USDT (6 decimals)
    uint256 public constant ETH_COLLATERAL = 1 ether; // 1 ETH

    event CollateralLocked(
        uint256 indexed loanId,
        address indexed borrower,
        CollateralManager.CollateralType collateralType,
        uint256 amount,
        uint256 loanAmount
    );
    event CollateralReleased(uint256 indexed loanId, address indexed borrower, uint256 amount);
    event CollateralLiquidated(
        uint256 indexed loanId,
        address indexed liquidator,
        address indexed borrower,
        uint256 collateralAmount,
        uint256 liquidatorReward
    );

    function setUp() public {
        // Deploy contracts
        usdt = new MockUSDT();
        priceFeed = new MockPriceFeed(int256(INITIAL_ETH_PRICE), 8, "ETH / USD");
        collateralManager = new CollateralManager(address(usdt), address(priceFeed));

        // Setup borrower with USDT and ETH
        usdt.mint(borrower, 10000e6);
        vm.deal(borrower, 100 ether);
        vm.deal(liquidator, 10 ether);
    }

    // ============ ETH Collateral Tests ============

    function test_LockEthCollateral() public {
        uint256 loanId = 1;

        vm.prank(borrower);
        vm.expectEmit(true, true, false, true);
        emit CollateralLocked(loanId, borrower, CollateralManager.CollateralType.ETH, ETH_COLLATERAL, LOAN_AMOUNT);
        
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        (
            CollateralManager.CollateralType collateralType,
            uint256 amount,
            uint256 loanAmount,
            uint256 lockedAt,
            bool isActive
        ) = collateralManager.collaterals(loanId);

        assertEq(uint256(collateralType), uint256(CollateralManager.CollateralType.ETH));
        assertEq(amount, ETH_COLLATERAL);
        assertEq(loanAmount, LOAN_AMOUNT);
        assertEq(lockedAt, block.timestamp);
        assertTrue(isActive);
        assertEq(collateralManager.totalEthCollateral(borrower), ETH_COLLATERAL);
    }

    function test_RevertLockEthCollateral_ZeroAmount() public {
        vm.expectRevert(CollateralManager.InvalidCollateralAmount.selector);
        collateralManager.lockEthCollateral{value: 0}(1, borrower, LOAN_AMOUNT);
    }

    function test_RevertLockEthCollateral_ZeroLoanAmount() public {
        vm.expectRevert(CollateralManager.InvalidLoanAmount.selector);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(1, borrower, 0);
    }

    function test_RevertLockEthCollateral_AlreadyLocked() public {
        uint256 loanId = 1;

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        vm.prank(borrower);
        vm.expectRevert(CollateralManager.CollateralAlreadyLocked.selector);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);
    }

    // ============ USDT Collateral Tests ============

    function test_LockUsdtCollateral() public {
        uint256 loanId = 2;
        uint256 collateralAmount = 2000e6; // 2000 USDT collateral

        vm.startPrank(borrower);
        usdt.approve(address(collateralManager), collateralAmount);
        
        vm.expectEmit(true, true, false, true);
        emit CollateralLocked(loanId, borrower, CollateralManager.CollateralType.USDT, collateralAmount, LOAN_AMOUNT);
        
        collateralManager.lockUsdtCollateral(loanId, borrower, collateralAmount, LOAN_AMOUNT);
        vm.stopPrank();

        (
            CollateralManager.CollateralType collateralType,
            uint256 amount,
            uint256 loanAmount,
            ,
            bool isActive
        ) = collateralManager.collaterals(loanId);

        assertEq(uint256(collateralType), uint256(CollateralManager.CollateralType.USDT));
        assertEq(amount, collateralAmount);
        assertEq(loanAmount, LOAN_AMOUNT);
        assertTrue(isActive);
        assertEq(collateralManager.totalUsdtCollateral(borrower), collateralAmount);
    }

    function test_RevertLockUsdtCollateral_ZeroAmount() public {
        vm.prank(borrower);
        vm.expectRevert(CollateralManager.InvalidCollateralAmount.selector);
        collateralManager.lockUsdtCollateral(1, borrower, 0, LOAN_AMOUNT);
    }

    // ============ Release Collateral Tests ============

    function test_ReleaseEthCollateral() public {
        uint256 loanId = 1;

        // Lock collateral
        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        uint256 borrowerBalanceBefore = borrower.balance;

        // Release collateral (owner only)
        vm.expectEmit(true, true, false, true);
        emit CollateralReleased(loanId, borrower, ETH_COLLATERAL);
        collateralManager.releaseCollateral(loanId, borrower);

        (, , , , bool isActive) = collateralManager.collaterals(loanId);
        assertFalse(isActive);
        assertEq(borrower.balance, borrowerBalanceBefore + ETH_COLLATERAL);
        assertEq(collateralManager.totalEthCollateral(borrower), 0);
    }

    function test_ReleaseUsdtCollateral() public {
        uint256 loanId = 2;
        uint256 collateralAmount = 2000e6;

        // Lock collateral
        vm.startPrank(borrower);
        usdt.approve(address(collateralManager), collateralAmount);
        collateralManager.lockUsdtCollateral(loanId, borrower, collateralAmount, LOAN_AMOUNT);
        vm.stopPrank();

        uint256 borrowerBalanceBefore = usdt.balanceOf(borrower);

        // Release collateral
        collateralManager.releaseCollateral(loanId, borrower);

        (, , , , bool isActive) = collateralManager.collaterals(loanId);
        assertFalse(isActive);
        assertEq(usdt.balanceOf(borrower), borrowerBalanceBefore + collateralAmount);
        assertEq(collateralManager.totalUsdtCollateral(borrower), 0);
    }

    function test_RevertReleaseCollateral_NotActive() public {
        vm.expectRevert(CollateralManager.CollateralNotActive.selector);
        collateralManager.releaseCollateral(999, borrower);
    }

    // ============ Health Ratio Tests ============

    function test_GetHealthRatio_EthCollateral() public {
        uint256 loanId = 1;

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        // ETH price = $2000, collateral = 1 ETH = $2000
        // Loan = $1000
        // Health ratio = (2000 / 1000) * 100 = 200%
        uint256 healthRatio = collateralManager.getHealthRatio(loanId);
        assertEq(healthRatio, 200);
    }

    function test_GetHealthRatio_UsdtCollateral() public {
        uint256 loanId = 2;
        uint256 collateralAmount = 1500e6; // $1500 USDT

        vm.startPrank(borrower);
        usdt.approve(address(collateralManager), collateralAmount);
        collateralManager.lockUsdtCollateral(loanId, borrower, collateralAmount, LOAN_AMOUNT);
        vm.stopPrank();

        // USDT collateral = $1500
        // Loan = $1000
        // Health ratio = (1500 / 1000) * 100 = 150%
        uint256 healthRatio = collateralManager.getHealthRatio(loanId);
        assertEq(healthRatio, 150);
    }

    function test_GetHealthRatio_PriceChange() public {
        uint256 loanId = 1;

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        // Initial: $2000 ETH = 200% health ratio
        assertEq(collateralManager.getHealthRatio(loanId), 200);

        // Drop ETH price to $1000
        priceFeed.setPrice(1000e8);

        // New: $1000 ETH = 100% health ratio
        assertEq(collateralManager.getHealthRatio(loanId), 100);
    }

    // ============ Liquidation Tests ============

    function test_Liquidate_EthCollateral() public {
        uint256 loanId = 1;

        // Lock collateral at $2000 ETH (200% health ratio)
        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        // Drop ETH price to $1100 (110% health ratio - below 120% threshold)
        priceFeed.setPrice(1100e8);

        assertTrue(collateralManager.canLiquidate(loanId));

        uint256 liquidatorBalanceBefore = liquidator.balance;
        uint256 ownerBalanceBefore = owner.balance;

        // Liquidate
        vm.prank(liquidator);
        vm.expectEmit(true, true, true, true);
        emit CollateralLiquidated(loanId, liquidator, borrower, ETH_COLLATERAL, 0.05 ether);
        collateralManager.liquidate(loanId, borrower);

        // Check liquidator got 5% reward
        assertEq(liquidator.balance, liquidatorBalanceBefore + 0.05 ether);
        
        // Check owner got remaining 95%
        assertEq(owner.balance, ownerBalanceBefore + 0.95 ether);

        // Check collateral is inactive
        (, , , , bool isActive) = collateralManager.collaterals(loanId);
        assertFalse(isActive);
    }

    function test_Liquidate_UsdtCollateral() public {
        uint256 loanId = 2;
        uint256 collateralAmount = 1150e6; // $1150 USDT (115% health ratio)

        // Lock USDT collateral
        vm.startPrank(borrower);
        usdt.approve(address(collateralManager), collateralAmount);
        collateralManager.lockUsdtCollateral(loanId, borrower, collateralAmount, LOAN_AMOUNT);
        vm.stopPrank();

        assertTrue(collateralManager.canLiquidate(loanId));

        uint256 liquidatorReward = (collateralAmount * 5) / 100; // 5%
        uint256 protocolAmount = collateralAmount - liquidatorReward;
        
        uint256 ownerBalanceBefore = usdt.balanceOf(owner);

        // Liquidate
        vm.prank(liquidator);
        collateralManager.liquidate(loanId, borrower);

        // Check balances
        assertEq(usdt.balanceOf(liquidator), liquidatorReward);
        assertEq(usdt.balanceOf(owner), ownerBalanceBefore + protocolAmount);
    }

    function test_RevertLiquidate_HealthyLoan() public {
        uint256 loanId = 1;

        // Lock collateral with healthy 200% ratio
        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        assertFalse(collateralManager.canLiquidate(loanId));

        vm.prank(liquidator);
        vm.expectRevert(CollateralManager.LoanNotLiquidatable.selector);
        collateralManager.liquidate(loanId, borrower);
    }

    function test_Liquidate_ExactThreshold() public {
        uint256 loanId = 1;

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        // Set ETH price to exactly 120% threshold ($1200)
        priceFeed.setPrice(1200e8);

        uint256 healthRatio = collateralManager.getHealthRatio(loanId);
        assertEq(healthRatio, 120);

        // Should NOT be liquidatable at exact threshold
        assertFalse(collateralManager.canLiquidate(loanId));
    }

    function test_Liquidate_JustBelowThreshold() public {
        uint256 loanId = 1;

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        // Set ETH price just below threshold ($1190 = 119% ratio)
        priceFeed.setPrice(1190e8);

        uint256 healthRatio = collateralManager.getHealthRatio(loanId);
        assertEq(healthRatio, 119);

        // Should be liquidatable
        assertTrue(collateralManager.canLiquidate(loanId));
    }

    // ============ Price Oracle Tests ============

    function test_RevertGetHealthRatio_StalePrice() public {
        uint256 loanId = 1;

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        // Move time forward 2 hours, then set old timestamp
        vm.warp(block.timestamp + 2 hours);
        priceFeed.setUpdatedAt(block.timestamp - 2 hours);

        vm.expectRevert(CollateralManager.StalePriceData.selector);
        collateralManager.getHealthRatio(loanId);
    }

    function test_UpdatePriceOracle() public {
        MockPriceFeed newPriceFeed = new MockPriceFeed(2500e8, 8, "ETH / USD");
        
        collateralManager.updatePriceOracle(address(newPriceFeed));
        
        assertEq(address(collateralManager.priceOracle()), address(newPriceFeed));
    }

    function test_RevertUpdatePriceOracle_ZeroAddress() public {
        vm.expectRevert(CollateralManager.InvalidPriceOracle.selector);
        collateralManager.updatePriceOracle(address(0));
    }

    // ============ Collateral Value Tests ============

    function test_GetCollateralValue_EthCollateral() public {
        uint256 loanId = 1;

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        // ETH price = $2000, 1 ETH = $2000 (in 6 decimals)
        uint256 value = collateralManager.getCollateralValue(loanId);
        assertEq(value, 2000e6);
    }

    function test_GetCollateralValue_UsdtCollateral() public {
        uint256 loanId = 2;
        uint256 collateralAmount = 1500e6;

        vm.startPrank(borrower);
        usdt.approve(address(collateralManager), collateralAmount);
        collateralManager.lockUsdtCollateral(loanId, borrower, collateralAmount, LOAN_AMOUNT);
        vm.stopPrank();

        uint256 value = collateralManager.getCollateralValue(loanId);
        assertEq(value, collateralAmount);
    }

    // ============ Pause Tests ============

    function test_Pause() public {
        collateralManager.pause();

        vm.prank(borrower);
        vm.expectRevert();
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(1, borrower, LOAN_AMOUNT);
    }

    function test_Unpause() public {
        collateralManager.pause();
        collateralManager.unpause();

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(1, borrower, LOAN_AMOUNT);
    }

    // ============ Fuzz Tests ============

    function testFuzz_LockEthCollateral(uint256 ethAmount, uint256 loanAmount) public {
        // Bound inputs to reasonable ranges
        ethAmount = bound(ethAmount, 0.01 ether, 100 ether);
        loanAmount = bound(loanAmount, 100e6, 1000000e6); // $100 to $1M

        vm.deal(borrower, ethAmount);

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ethAmount}(1, borrower, loanAmount);

        (, uint256 amount, uint256 loan, , bool isActive) = collateralManager.collaterals(1);
        assertEq(amount, ethAmount);
        assertEq(loan, loanAmount);
        assertTrue(isActive);
    }

    function testFuzz_HealthRatio(uint256 ethPrice) public {
        // Bound ETH price between $100 and $10,000
        ethPrice = bound(ethPrice, 100e8, 10000e8);

        uint256 loanId = 1;

        vm.prank(borrower);
        collateralManager.lockEthCollateral{value: ETH_COLLATERAL}(loanId, borrower, LOAN_AMOUNT);

        priceFeed.setPrice(int256(ethPrice));

        uint256 healthRatio = collateralManager.getHealthRatio(loanId);
        
        // Calculate expected health ratio
        uint256 collateralValueUsd = (ETH_COLLATERAL * ethPrice) / 1e20; // Convert to 6 decimals
        uint256 expectedRatio = (collateralValueUsd * 100) / LOAN_AMOUNT;
        
        assertEq(healthRatio, expectedRatio);
    }

    // ============ Multiple Loans Tests ============

    function test_MultipleLoansSameBorrower() public {
        uint256 loan1 = 1;
        uint256 loan2 = 2;

        vm.startPrank(borrower);
        
        // Lock ETH for loan 1
        collateralManager.lockEthCollateral{value: 1 ether}(loan1, borrower, LOAN_AMOUNT);
        
        // Lock USDT for loan 2
        usdt.approve(address(collateralManager), 2000e6);
        collateralManager.lockUsdtCollateral(loan2, borrower, 2000e6, LOAN_AMOUNT);
        
        vm.stopPrank();

        // Check both loans are active
        (, , , , bool active1) = collateralManager.collaterals(loan1);
        (, , , , bool active2) = collateralManager.collaterals(loan2);
        assertTrue(active1);
        assertTrue(active2);

        // Check totals
        assertEq(collateralManager.totalEthCollateral(borrower), 1 ether);
        assertEq(collateralManager.totalUsdtCollateral(borrower), 2000e6);
    }

    receive() external payable {}
}

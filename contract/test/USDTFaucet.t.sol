// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/USDTFaucet.sol";
import "../src/MockUSDT.sol";

contract USDTFaucetTest is Test {
    USDTFaucet public faucet;
    MockUSDT public usdt;
    address public owner;
    address public user1;
    address public user2;

    uint256 constant CLAIM_AMOUNT = 1000 * 10 ** 6;
    uint256 constant CLAIM_INTERVAL = 24 hours;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy USDT and Faucet
        usdt = new MockUSDT();
        faucet = new USDTFaucet(address(usdt));
        
        // Fund faucet with 100,000 USDT
        usdt.mint(address(faucet), 100_000 * 10 ** 6);
    }

    function test_InitialSetup() public view {
        assertEq(address(faucet.usdtToken()), address(usdt));
        assertEq(faucet.CLAIM_AMOUNT(), CLAIM_AMOUNT);
        assertEq(faucet.CLAIM_INTERVAL(), CLAIM_INTERVAL);
        assertEq(faucet.owner(), owner);
    }

    function test_GetClaimAmount() public view {
        assertEq(faucet.getClaimAmount(), CLAIM_AMOUNT);
    }

    function test_GetFaucetBalance() public view {
        assertEq(faucet.getFaucetBalance(), 100_000 * 10 ** 6);
    }

    function test_ClaimTokens() public {
        uint256 initialBalance = usdt.balanceOf(user1);
        
        vm.prank(user1);
        bool success = faucet.claimTokens();
        
        assertTrue(success);
        assertEq(usdt.balanceOf(user1), initialBalance + CLAIM_AMOUNT);
        assertEq(faucet.lastClaimTime(user1), block.timestamp);
        assertEq(faucet.totalClaims(), 1);
        assertEq(faucet.totalDistributed(), CLAIM_AMOUNT);
    }

    function test_ClaimTokensMultipleUsers() public {
        vm.prank(user1);
        faucet.claimTokens();
        
        vm.prank(user2);
        faucet.claimTokens();
        
        assertEq(usdt.balanceOf(user1), CLAIM_AMOUNT);
        assertEq(usdt.balanceOf(user2), CLAIM_AMOUNT);
        assertEq(faucet.totalClaims(), 2);
        assertEq(faucet.totalDistributed(), CLAIM_AMOUNT * 2);
    }

    function test_CanClaimInitially() public view {
        assertTrue(faucet.canClaim(user1));
    }

    function test_CannotClaimTwiceWithin24Hours() public {
        vm.prank(user1);
        faucet.claimTokens();
        
        assertFalse(faucet.canClaim(user1));
    }

    function test_RevertClaimTooSoon() public {
        vm.prank(user1);
        faucet.claimTokens();
        
        vm.prank(user1);
        vm.expectRevert("USDTFaucet: claim too soon");
        faucet.claimTokens();
    }

    function test_ClaimAfter24Hours() public {
        vm.prank(user1);
        faucet.claimTokens();
        
        // Fast forward 24 hours
        vm.warp(block.timestamp + CLAIM_INTERVAL);
        
        assertTrue(faucet.canClaim(user1));
        
        vm.prank(user1);
        faucet.claimTokens();
        
        assertEq(usdt.balanceOf(user1), CLAIM_AMOUNT * 2);
        assertEq(faucet.totalClaims(), 2);
    }

    function test_GetNextClaimTime() public {
        // Initially should be 0 (can claim now)
        assertEq(faucet.getNextClaimTime(user1), 0);
        
        vm.prank(user1);
        faucet.claimTokens();
        
        // Should be 24 hours
        assertEq(faucet.getNextClaimTime(user1), CLAIM_INTERVAL);
        
        // Fast forward 12 hours
        vm.warp(block.timestamp + 12 hours);
        assertEq(faucet.getNextClaimTime(user1), 12 hours);
        
        // Fast forward another 12 hours
        vm.warp(block.timestamp + 12 hours);
        assertEq(faucet.getNextClaimTime(user1), 0);
    }

    function test_RevertInsufficientFaucetBalance() public {
        // Deploy new faucet with no balance
        USDTFaucet emptyFaucet = new USDTFaucet(address(usdt));
        
        vm.prank(user1);
        vm.expectRevert("USDTFaucet: insufficient balance");
        emptyFaucet.claimTokens();
    }

    function test_RefillFaucet() public {
        uint256 refillAmount = 50_000 * 10 ** 6;
        uint256 initialBalance = faucet.getFaucetBalance();
        
        // Mint to owner and approve
        usdt.mint(owner, refillAmount);
        usdt.approve(address(faucet), refillAmount);
        
        faucet.refillFaucet(refillAmount);
        
        assertEq(faucet.getFaucetBalance(), initialBalance + refillAmount);
    }

    function test_RefillFaucetByNonOwner() public {
        uint256 refillAmount = 10_000 * 10 ** 6;
        
        // Mint to user1 and approve
        usdt.mint(user1, refillAmount);
        
        vm.startPrank(user1);
        usdt.approve(address(faucet), refillAmount);
        faucet.refillFaucet(refillAmount);
        vm.stopPrank();
        
        assertEq(faucet.getFaucetBalance(), 110_000 * 10 ** 6);
    }

    function test_RevertRefillZeroAmount() public {
        vm.expectRevert("USDTFaucet: zero amount");
        faucet.refillFaucet(0);
    }

    function test_EmergencyWithdraw() public {
        uint256 withdrawAmount = 50_000 * 10 ** 6;
        uint256 initialOwnerBalance = usdt.balanceOf(owner);
        
        faucet.emergencyWithdraw(withdrawAmount);
        
        assertEq(usdt.balanceOf(owner), initialOwnerBalance + withdrawAmount);
        assertEq(faucet.getFaucetBalance(), 50_000 * 10 ** 6);
    }

    function test_RevertEmergencyWithdrawNotOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        faucet.emergencyWithdraw(1000 * 10 ** 6);
    }

    function test_RevertEmergencyWithdrawZeroAmount() public {
        vm.expectRevert("USDTFaucet: zero amount");
        faucet.emergencyWithdraw(0);
    }

    function test_EventTokensClaimed() public {
        vm.expectEmit(true, false, false, true);
        emit USDTFaucet.TokensClaimed(user1, CLAIM_AMOUNT, block.timestamp);
        
        vm.prank(user1);
        faucet.claimTokens();
    }

    function test_EventFaucetRefilled() public {
        uint256 refillAmount = 10_000 * 10 ** 6;
        usdt.mint(owner, refillAmount);
        usdt.approve(address(faucet), refillAmount);
        
        vm.expectEmit(true, false, false, true);
        emit USDTFaucet.FaucetRefilled(owner, refillAmount);
        
        faucet.refillFaucet(refillAmount);
    }

    function testFuzz_ClaimAfterRandomTime(uint256 timeElapsed) public {
        vm.assume(timeElapsed >= CLAIM_INTERVAL);
        vm.assume(timeElapsed <= 365 days); // Cap at 1 year
        
        vm.prank(user1);
        faucet.claimTokens();
        
        vm.warp(block.timestamp + timeElapsed);
        
        assertTrue(faucet.canClaim(user1));
        
        vm.prank(user1);
        faucet.claimTokens();
        
        assertEq(usdt.balanceOf(user1), CLAIM_AMOUNT * 2);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MockUSDT.sol";

contract MockUSDTTest is Test {
    MockUSDT public usdt;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        usdt = new MockUSDT();
    }

    function test_InitialSetup() public view {
        assertEq(usdt.name(), "Mock USDT");
        assertEq(usdt.symbol(), "USDT");
        assertEq(usdt.decimals(), 6);
        assertEq(usdt.owner(), owner);
    }

    function test_InitialSupply() public view {
        // Owner should have 1 million USDT
        assertEq(usdt.balanceOf(owner), 1_000_000 * 10 ** 6);
    }

    function test_Mint() public {
        uint256 mintAmount = 5000 * 10 ** 6; // 5000 USDT
        
        usdt.mint(user1, mintAmount);
        
        assertEq(usdt.balanceOf(user1), mintAmount);
    }

    function test_MintMultipleUsers() public {
        uint256 amount1 = 1000 * 10 ** 6;
        uint256 amount2 = 2000 * 10 ** 6;
        
        usdt.mint(user1, amount1);
        usdt.mint(user2, amount2);
        
        assertEq(usdt.balanceOf(user1), amount1);
        assertEq(usdt.balanceOf(user2), amount2);
    }

    function test_RevertMintToZeroAddress() public {
        vm.expectRevert("MockUSDT: mint to zero address");
        usdt.mint(address(0), 1000 * 10 ** 6);
    }

    function test_RevertMintZeroAmount() public {
        vm.expectRevert("MockUSDT: mint amount zero");
        usdt.mint(user1, 0);
    }

    function test_RevertMintNotOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        usdt.mint(user2, 1000 * 10 ** 6);
    }

    function test_Burn() public {
        uint256 mintAmount = 5000 * 10 ** 6;
        uint256 burnAmount = 2000 * 10 ** 6;
        
        usdt.mint(user1, mintAmount);
        
        vm.prank(user1);
        usdt.burn(burnAmount);
        
        assertEq(usdt.balanceOf(user1), mintAmount - burnAmount);
    }

    function test_RevertBurnZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert("MockUSDT: burn amount zero");
        usdt.burn(0);
    }

    function test_RevertBurnInsufficientBalance() public {
        usdt.mint(user1, 1000 * 10 ** 6);
        
        vm.prank(user1);
        vm.expectRevert();
        usdt.burn(2000 * 10 ** 6);
    }

    function test_Transfer() public {
        uint256 amount = 1000 * 10 ** 6;
        
        usdt.mint(user1, amount);
        
        vm.prank(user1);
        usdt.transfer(user2, amount / 2);
        
        assertEq(usdt.balanceOf(user1), amount / 2);
        assertEq(usdt.balanceOf(user2), amount / 2);
    }

    function test_Approve() public {
        uint256 amount = 1000 * 10 ** 6;
        
        vm.prank(user1);
        usdt.approve(user2, amount);
        
        assertEq(usdt.allowance(user1, user2), amount);
    }

    function test_TransferFrom() public {
        uint256 amount = 1000 * 10 ** 6;
        
        usdt.mint(user1, amount);
        
        vm.prank(user1);
        usdt.approve(user2, amount);
        
        vm.prank(user2);
        usdt.transferFrom(user1, user2, amount);
        
        assertEq(usdt.balanceOf(user2), amount);
        assertEq(usdt.balanceOf(user1), 0);
    }

    function testFuzz_Mint(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount <= type(uint128).max); // Avoid overflow
        
        usdt.mint(user1, amount);
        assertEq(usdt.balanceOf(user1), amount);
    }
}

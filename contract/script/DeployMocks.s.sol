// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MockUSDT.sol";
import "../src/USDTFaucet.sol";

/**
 * @title DeployMocks
 * @notice Deployment script for MockUSDT and USDTFaucet on Mantle testnet
 */
contract DeployMocks is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy MockUSDT
        console.log("Deploying MockUSDT...");
        MockUSDT usdt = new MockUSDT();
        console.log("MockUSDT deployed at:", address(usdt));
        console.log("Initial supply:", usdt.totalSupply() / 10 ** 6, "USDT");
        
        // Deploy USDTFaucet
        console.log("\nDeploying USDTFaucet...");
        USDTFaucet faucet = new USDTFaucet(address(usdt));
        console.log("USDTFaucet deployed at:", address(faucet));
        
        // Fund faucet with 100,000 USDT
        uint256 faucetFunding = 100_000 * 10 ** 6;
        console.log("\nFunding faucet with", faucetFunding / 10 ** 6, "USDT...");
        usdt.transfer(address(faucet), faucetFunding);
        console.log("Faucet funded successfully");
        
        vm.stopBroadcast();
        
        // Log deployment summary
        console.log("\n========== DEPLOYMENT SUMMARY ==========");
        console.log("MockUSDT:", address(usdt));
        console.log("USDTFaucet:", address(faucet));
        console.log("Faucet Balance:", faucet.getFaucetBalance() / 10 ** 6, "USDT");
        console.log("Claim Amount:", faucet.getClaimAmount() / 10 ** 6, "USDT");
        console.log("Claim Interval:", faucet.CLAIM_INTERVAL() / 1 hours, "hours");
        console.log("=======================================");
    }
}

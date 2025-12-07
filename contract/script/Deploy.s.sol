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
 * @title Deploy
 * @notice Comprehensive deployment script for OnLoan protocol
 * @dev Deploys all contracts in correct order with proper initialization
 * 
 * Usage:
 * 1. Local Anvil: forge script script/Deploy.s.sol --fork-url http://localhost:8545 --broadcast
 * 2. Mantle Sepolia: forge script script/Deploy.s.sol --rpc-url $MANTLE_SEPOLIA_RPC --broadcast --verify
 */
contract Deploy is Script {
    // Deployment addresses (will be set during deployment)
    MockUSDT public usdt;
    USDTFaucet public faucet;
    InterestCalculator public interestCalculator;
    CollateralManager public collateralManager;
    CreditScore public creditScore;
    LendingPool public lendingPool;
    LoanManager public loanManager;

    // Configuration
    uint256 public constant INITIAL_FAUCET_SUPPLY = 1_000_000 * 10 ** 6; // 1M USDT
    uint256 public constant FAUCET_CLAIM_AMOUNT = 1_000 * 10 ** 6; // 1000 USDT per claim
    
    // Mantle Sepolia Chainlink Price Feed (ETH/USD)
    // Note: Replace with actual Mantle Sepolia oracle address if available
    // For testnet, we'll deploy a mock oracle
    address public ethUsdPriceFeed;

    function run() external {
        // Load deployment private key from environment (or use Anvil default for local)
        uint256 deployerPrivateKey;
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            deployerPrivateKey = key;
        } catch {
            // Use Anvil's default key for local deployment
            deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        }
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("=== OnLoan Protocol Deployment ===");
        console.log("Deployer:", deployer);
        console.log("Chain ID:", block.chainid);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy MockUSDT
        console.log("1. Deploying MockUSDT...");
        usdt = new MockUSDT();
        console.log("   MockUSDT deployed at:", address(usdt));

        // Step 2: Deploy USDTFaucet
        console.log("2. Deploying USDTFaucet...");
        faucet = new USDTFaucet(address(usdt));
        console.log("   USDTFaucet deployed at:", address(faucet));

        // Step 3: Fund faucet with initial supply
        console.log("3. Funding faucet with initial USDT...");
        usdt.mint(address(faucet), INITIAL_FAUCET_SUPPLY);
        console.log("   Faucet funded with:", INITIAL_FAUCET_SUPPLY / 10 ** 6, "USDT");

        // Step 4: Deploy InterestCalculator
        console.log("4. Deploying InterestCalculator...");
        interestCalculator = new InterestCalculator();
        console.log("   InterestCalculator deployed at:", address(interestCalculator));

        // Step 5: Deploy or use existing price feed
        console.log("5. Setting up Price Oracle...");
        ethUsdPriceFeed = deployPriceOracle();
        console.log("   ETH/USD Price Feed at:", ethUsdPriceFeed);

        // Step 6: Deploy CollateralManager
        console.log("6. Deploying CollateralManager...");
        collateralManager = new CollateralManager(address(usdt), ethUsdPriceFeed);
        console.log("   CollateralManager deployed at:", address(collateralManager));

        // Step 7: Deploy CreditScore
        console.log("7. Deploying CreditScore...");
        creditScore = new CreditScore();
        console.log("   CreditScore deployed at:", address(creditScore));

        // Step 8: Deploy LendingPool
        console.log("8. Deploying LendingPool...");
        lendingPool = new LendingPool(address(usdt), address(interestCalculator));
        console.log("   LendingPool deployed at:", address(lendingPool));

        // Step 9: Deploy LoanManager with protocol treasury
        console.log("9. Deploying LoanManager...");
        address protocolTreasury = deployer; // Use deployer as treasury for now
        loanManager = new LoanManager(
            address(usdt),
            address(collateralManager),
            address(interestCalculator),
            address(creditScore),
            address(lendingPool),
            protocolTreasury
        );
        console.log("   LoanManager deployed at:", address(loanManager));
        console.log("   Protocol Treasury set to:", protocolTreasury);

        // Step 10: Initialize contract permissions
        console.log("10. Initializing contract permissions...");
        
        // Set LoanManager in CreditScore
        creditScore.setLoanManager(address(loanManager));
        console.log("    CreditScore: LoanManager authorized");
        
        // Transfer CollateralManager ownership to LoanManager
        collateralManager.transferOwnership(address(loanManager));
        console.log("    CollateralManager: Ownership transferred to LoanManager");
        
        // Set LoanManager in LendingPool
        lendingPool.setLoanManager(address(loanManager));
        console.log("    LendingPool: LoanManager authorized");

        vm.stopBroadcast();

        // Print deployment summary
        console.log("");
        console.log("=== Deployment Complete ===");
        console.log("");
        printDeploymentSummary();
        
        // Note: Deployment addresses printed above
        // Save to deployments/ directory manually if needed
    }

    /**
     * @notice Deploy or return existing price oracle
     * @dev For Mantle Sepolia, use Chainlink oracle if available, otherwise deploy mock
     */
    function deployPriceOracle() internal returns (address) {
        // Check if we're on Mantle Sepolia (Chain ID: 5003)
        if (block.chainid == 5003) {
            // Try to use existing Chainlink oracle
            // Note: Update this with actual Mantle Sepolia Chainlink address when available
            // For now, deploy mock oracle
            console.log("   Deploying Mock Price Feed for testnet...");
            return deployMockPriceFeed();
        } else {
            // Local development - deploy mock
            console.log("   Deploying Mock Price Feed for local testing...");
            return deployMockPriceFeed();
        }
    }

    /**
     * @notice Deploy mock price feed for testing
     * @dev Returns ETH/USD price of $2000 with 8 decimals
     */
    function deployMockPriceFeed() internal returns (address) {
        // Deploy mock price feed contract (simplified version)
        bytes memory bytecode = type(MockPriceFeed).creationCode;
        address mockOracle;
        assembly {
            mockOracle := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        return mockOracle;
    }

    /**
     * @notice Print deployment summary
     */
    function printDeploymentSummary() internal view {
        console.log("Contract Addresses:");
        console.log("-------------------");
        console.log("MockUSDT:           ", address(usdt));
        console.log("USDTFaucet:         ", address(faucet));
        console.log("InterestCalculator: ", address(interestCalculator));
        console.log("CollateralManager:  ", address(collateralManager));
        console.log("CreditScore:        ", address(creditScore));
        console.log("LendingPool:        ", address(lendingPool));
        console.log("LoanManager:        ", address(loanManager));
        console.log("ETH/USD Oracle:     ", ethUsdPriceFeed);
        console.log("");
        console.log("Configuration:");
        console.log("--------------");
        console.log("Faucet Claim Amount: ", FAUCET_CLAIM_AMOUNT / 10 ** 6, "USDT");
        console.log("Faucet Total Supply: ", INITIAL_FAUCET_SUPPLY / 10 ** 6, "USDT");
        console.log("Protocol Fee:        10% of interest");
        console.log("");
    }

    /**
     * @notice Save deployment addresses to JSON file
     */
    function saveDeploymentAddresses() internal {
        string memory json = string.concat(
            '{\n',
            '  "chainId": ', vm.toString(block.chainid), ',\n',
            '  "deployer": "', vm.toString(msg.sender), '",\n',
            '  "timestamp": ', vm.toString(block.timestamp), ',\n',
            '  "contracts": {\n',
            '    "MockUSDT": "', vm.toString(address(usdt)), '",\n',
            '    "USDTFaucet": "', vm.toString(address(faucet)), '",\n',
            '    "InterestCalculator": "', vm.toString(address(interestCalculator)), '",\n',
            '    "CollateralManager": "', vm.toString(address(collateralManager)), '",\n',
            '    "CreditScore": "', vm.toString(address(creditScore)), '",\n',
            '    "LendingPool": "', vm.toString(address(lendingPool)), '",\n',
            '    "LoanManager": "', vm.toString(address(loanManager)), '",\n',
            '    "ETHUSDOracle": "', vm.toString(ethUsdPriceFeed), '"\n',
            '  }\n',
            '}'
        );

        string memory filename = string.concat("deployments/deployment-", vm.toString(block.chainid), ".json");
        vm.writeFile(filename, json);
        console.log("Deployment addresses saved to:", filename);
    }
}

/**
 * @title MockPriceFeed
 * @notice Simple mock Chainlink aggregator for testing
 */
contract MockPriceFeed {
    int256 private constant PRICE = 2000e8; // $2000 with 8 decimals
    uint8 private constant DECIMALS = 8;
    string private constant DESCRIPTION = "ETH / USD";
    uint256 private constant VERSION = 1;

    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }

    function description() external pure returns (string memory) {
        return DESCRIPTION;
    }

    function version() external pure returns (uint256) {
        return VERSION;
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (1, PRICE, block.timestamp, block.timestamp, 1);
    }

    function getRoundData(uint80)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (1, PRICE, block.timestamp, block.timestamp, 1);
    }
}

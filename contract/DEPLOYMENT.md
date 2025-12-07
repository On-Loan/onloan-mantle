# OnLoan Protocol Deployment Guide

## 📋 Overview

This document contains deployment information and instructions for the OnLoan P2P lending protocol on Mantle Sepolia testnet.

## 🏗️ Architecture

The OnLoan protocol consists of 7 core smart contracts:

1. **MockUSDT** - Test USDT token (ERC20, 6 decimals)
2. **USDTFaucet** - Faucet for claiming test USDT (1000 USDT per 24 hours)
3. **InterestCalculator** - Calculates interest rates and APY
4. **CollateralManager** - Manages collateral locking and liquidations
5. **CreditScore** - Tracks user credit scores (300-1000 range)
6. **LendingPool** - Handles deposits, withdrawals, and interest distribution
7. **LoanManager** - Core loan lifecycle management and protocol fees

## 📍 Deployed Contracts (Mantle Sepolia)

> **Note**: Update these addresses after deployment

| Contract | Address | Explorer Link |
|----------|---------|---------------|
| MockUSDT | `0x...` | [View on Explorer](#) |
| USDTFaucet | `0x...` | [View on Explorer](#) |
| InterestCalculator | `0x...` | [View on Explorer](#) |
| CollateralManager | `0x...` | [View on Explorer](#) |
| CreditScore | `0x...` | [View on Explorer](#) |
| LendingPool | `0x...` | [View on Explorer](#) |
| LoanManager | `0x...` | [View on Explorer](#) |
| ETH/USD Oracle | `0x...` | [View on Explorer](#) |

**Protocol Treasury**: `0x...`

---

## 🚀 Deployment Instructions

### Prerequisites

1. **Install Foundry**:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Set up environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env and add:
   # PRIVATE_KEY=your_private_key
   # MANTLE_SEPOLIA_RPC=https://rpc.sepolia.mantle.xyz
   # ETHERSCAN_API_KEY=your_api_key (for verification)
   ```

3. **Fund deployer wallet**:
   - Get MNT testnet tokens from [Mantle Faucet](https://faucet.sepolia.mantle.xyz/)
   - Ensure you have enough MNT for gas fees (~0.1 MNT should be sufficient)

### Local Deployment (Anvil)

Test deployment locally before deploying to testnet:

```bash
# Terminal 1: Start local Anvil node
anvil

# Terminal 2: Deploy contracts
forge script script/Deploy.s.sol --fork-url http://localhost:8545 --broadcast

# Verify deployment
forge script script/Verify.s.sol --fork-url http://localhost:8545
```

### Mantle Sepolia Deployment

1. **Compile contracts**:
   ```bash
   forge build
   ```

2. **Run tests**:
   ```bash
   forge test
   ```
   Ensure all 192 tests pass before deploying.

3. **Deploy to Mantle Sepolia**:
   ```bash
   forge script script/Deploy.s.sol \
     --rpc-url $MANTLE_SEPOLIA_RPC \
     --broadcast \
     --verify \
     --legacy
   ```

4. **Verify contracts** (if auto-verification fails):
   ```bash
   # MockUSDT
   forge verify-contract <address> src/MockUSDT.sol:MockUSDT \
     --chain-id 5003 \
     --etherscan-api-key $ETHERSCAN_API_KEY

   # USDTFaucet
   forge verify-contract <address> src/USDTFaucet.sol:USDTFaucet \
     --constructor-args $(cast abi-encode "constructor(address,uint256)" <usdt_address> <claim_amount>) \
     --chain-id 5003 \
     --etherscan-api-key $ETHERSCAN_API_KEY

   # Repeat for other contracts...
   ```

5. **Run post-deployment verification**:
   ```bash
   # Update addresses in Verify.s.sol first
   forge script script/Verify.s.sol --rpc-url $MANTLE_SEPOLIA_RPC
   ```

---

## 🔧 Configuration

### Protocol Parameters

- **Faucet Claim Amount**: 1,000 USDT
- **Faucet Cooldown**: 24 hours
- **Protocol Fee**: 10% of interest (1000 basis points)
- **Minimum Loan Amount**: 100 USDT
- **Maximum Loan Duration**: 365 days
- **Minimum Loan Duration**: 7 days
- **Liquidation Threshold**: 120% collateral ratio
- **Liquidation Grace Period**: 3 days

### Loan Types & Interest Rates

| Loan Type | Base Rate | Description |
|-----------|-----------|-------------|
| Personal | 8% APY | General personal loans |
| Home | 5% APY | Home-related financing |
| Business | 10% APY | Business capital loans |
| Auto | 6% APY | Vehicle financing |

### Credit Score Tiers

| Score Range | Tier | Collateral Requirement |
|-------------|------|------------------------|
| 800-1000 | Excellent | 110% |
| 700-799 | Good | 120% |
| 600-699 | Fair | 130% |
| 500-599 | Poor | 140% |
| 300-499 | Very Poor | 150% |

---

## 🧪 Testing Deployment

### 1. Claim Test USDT

```bash
# Using cast
cast send <faucet_address> "claimTokens()" \
  --rpc-url $MANTLE_SEPOLIA_RPC \
  --private-key $PRIVATE_KEY

# Check balance
cast call <usdt_address> "balanceOf(address)(uint256)" <your_address> \
  --rpc-url $MANTLE_SEPOLIA_RPC
```

### 2. Deposit to Lending Pool

```bash
# Approve USDT
cast send <usdt_address> "approve(address,uint256)" <lending_pool_address> 1000000000 \
  --rpc-url $MANTLE_SEPOLIA_RPC \
  --private-key $PRIVATE_KEY

# Deposit
cast send <lending_pool_address> "deposit(uint256)" 1000000000 \
  --rpc-url $MANTLE_SEPOLIA_RPC \
  --private-key $PRIVATE_KEY
```

### 3. Create a Loan

```bash
# Create loan with ETH collateral
cast send <loan_manager_address> "createLoanWithEth(uint256,uint8,uint256)" 500000000 0 30 \
  --value 0.5ether \
  --rpc-url $MANTLE_SEPOLIA_RPC \
  --private-key $PRIVATE_KEY
```

---

## 📊 Monitoring & Maintenance

### View Pool Stats

```bash
# Get lending pool stats
cast call <lending_pool_address> "getPoolStats()(uint256,uint256,uint256,uint256)" \
  --rpc-url $MANTLE_SEPOLIA_RPC
```

### Check Protocol Fees

```bash
# Get protocol fee info
cast call <loan_manager_address> "getProtocolFeeInfo()(uint256,uint256,address)" \
  --rpc-url $MANTLE_SEPOLIA_RPC
```

### Withdraw Protocol Fees (Owner Only)

```bash
cast send <loan_manager_address> "withdrawProtocolFees()" \
  --rpc-url $MANTLE_SEPOLIA_RPC \
  --private-key $OWNER_PRIVATE_KEY
```

---

## 🔐 Security Considerations

1. **Private Key Management**:
   - Never commit `.env` files
   - Use hardware wallets for mainnet
   - Rotate keys regularly

2. **Access Control**:
   - CollateralManager owned by LoanManager
   - Only LoanManager can authorize CreditScore updates
   - Protocol owner can pause contracts in emergencies

3. **Oracle Reliability**:
   - Price feeds have 1-hour staleness check
   - Can update oracle address if needed
   - Monitor oracle uptime

4. **Upgradability**:
   - Current contracts are NOT upgradeable
   - Plan for redeployment if critical bugs found
   - Consider proxy pattern for future versions

---

## 📚 Additional Resources

- **Mantle Documentation**: https://docs.mantle.xyz/
- **Mantle Sepolia Explorer**: https://explorer.sepolia.mantle.xyz/
- **Mantle Sepolia Faucet**: https://faucet.sepolia.mantle.xyz/
- **Foundry Book**: https://book.getfoundry.sh/

---

## 🐛 Troubleshooting

### Common Issues

1. **"Insufficient funds" error**:
   - Ensure deployer wallet has MNT for gas
   - Get tokens from Mantle faucet

2. **Verification fails**:
   - Manually verify using `forge verify-contract`
   - Check constructor arguments match deployment

3. **Transaction reverts**:
   - Check contract permissions are set correctly
   - Verify contracts are initialized in correct order

4. **Oracle price stale**:
   - Deploy new mock oracle with recent timestamp
   - Update oracle address in CollateralManager

---

## 📝 Deployment Checklist

- [ ] Compile all contracts successfully
- [ ] Run and pass all 192 tests
- [ ] Set environment variables
- [ ] Fund deployer wallet with MNT
- [ ] Deploy to local Anvil first
- [ ] Test full user flow on Anvil
- [ ] Deploy to Mantle Sepolia
- [ ] Verify all contracts on explorer
- [ ] Run post-deployment verification script
- [ ] Fund faucet with USDT
- [ ] Test faucet claims
- [ ] Test deposit/withdraw flow
- [ ] Test loan creation and repayment
- [ ] Update frontend with contract addresses
- [ ] Document all deployment addresses
- [ ] Set up monitoring/alerts

---

**Last Updated**: December 7, 2025  
**Network**: Mantle Sepolia (Chain ID: 5003)  
**Protocol Version**: 1.0.0

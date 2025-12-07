# OnLoan Smart Contracts

OnLoan is a decentralized P2P lending protocol built on Mantle network, enabling users to lend and borrow USDT with dynamic interest rates, credit scoring, and collateralized loans.

## 📋 Contract Architecture

| Contract | Description | Lines of Code |
|----------|-------------|---------------|
| **MockUSDT** | Test USDT token (ERC20, 6 decimals) | ~150 |
| **USDTFaucet** | Testnet faucet (1000 USDT per 24h) | ~100 |
| **InterestCalculator** | Interest rate & APY calculations | ~200 |
| **CollateralManager** | Collateral locking & liquidations | ~350 |
| **CreditScore** | User reputation system (300-1000) | ~200 |
| **LendingPool** | Deposit/withdraw & interest distribution | ~400 |
| **LoanManager** | Loan lifecycle & protocol fees | ~450 |

**Total**: ~1,850 lines of Solidity + comprehensive test suite (192 tests)

## 🎯 Key Features

- ✅ **Dynamic Interest Rates**: Utilization-based APY (3-20%)
- ✅ **Credit Scoring**: Reputation system affects collateral requirements
- ✅ **Multiple Loan Types**: Personal (8%), Home (5%), Business (10%), Auto (6%)
- ✅ **Dual Collateral**: Support for ETH and USDT
- ✅ **Protocol Revenue**: 10% fee on all loan interest
- ✅ **Liquidation System**: Automated at 120% threshold
- ✅ **Proportional Interest**: Lenders earn based on deposit share

## 🏗️ Foundry Setup

### Prerequisites

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Build

```bash
forge build
```

### Test

```bash
# Run all 192 tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test
forge test --match-test testLoanCreation

# Gas report
forge test --gas-report

# Coverage
forge coverage
```

### Format Code

```bash
forge fmt
```

### Gas Snapshots

```bash
forge snapshot
```

## 🚀 Deployment

### Local Development (Anvil)

```bash
# Terminal 1: Start Anvil
anvil

# Terminal 2: Deploy contracts
forge script script/Deploy.s.sol --fork-url http://localhost:8545 --broadcast

# Verify deployment
forge script script/Verify.s.sol --fork-url http://localhost:8545
```

### Mantle Sepolia Testnet

1. **Set up environment**:
   ```bash
   cp .env.example .env
   # Add your private key and RPC URL to .env
   ```

2. **Get testnet tokens**:
   - Visit [Mantle Faucet](https://faucet.sepolia.mantle.xyz/)
   - Get MNT for gas fees

3. **Deploy**:
   ```bash
   forge script script/Deploy.s.sol \
     --rpc-url $MANTLE_SEPOLIA_RPC \
     --broadcast \
     --verify \
     --legacy
   ```

4. **Verify deployment**:
   ```bash
   forge script script/Verify.s.sol --rpc-url $MANTLE_SEPOLIA_RPC
   ```

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment guide and troubleshooting.

## 📍 Deployed Contracts (Mantle Sepolia)

> **Network**: Mantle Sepolia (Chain ID: 5003)  
> **RPC**: https://rpc.sepolia.mantle.xyz  
> **Explorer**: https://explorer.sepolia.mantle.xyz/

| Contract | Address |
|----------|---------|
| MockUSDT | `TBD` |
| USDTFaucet | `TBD` |
| InterestCalculator | `TBD` |
| CollateralManager | `TBD` |
| CreditScore | `TBD` |
| LendingPool | `TBD` |
| LoanManager | `TBD` |

**Last Deployment**: TBD  
**Protocol Treasury**: TBD

## 🧪 Testing

### Test Coverage

- **Unit Tests**: Each contract has comprehensive unit tests
- **Integration Tests**: Full user flow testing (deposit → borrow → repay)
- **Edge Cases**: Liquidations, partial repayments, multiple loans
- **Fuzz Testing**: Random input testing for robustness

### Test Results

```
Test Suites: 9
Total Tests: 192
✓ Passing: 192
✗ Failing: 0
```

### Run Specific Test Suites

```bash
# Lending pool tests
forge test --match-contract LendingPool

# Loan manager tests
forge test --match-contract LoanManager

# Integration tests
forge test --match-contract Integration
```

## 📊 Protocol Parameters

### Interest Rates
- **Base Rate**: 3% APY
- **Optimal Utilization**: 80%
- **Personal Loans**: 8% APY
- **Home Loans**: 5% APY
- **Business Loans**: 10% APY
- **Auto Loans**: 6% APY

### Protocol Fees
- **Interest Fee**: 10% of borrower interest
- **Lender Share**: 90% of borrower interest

### Credit Score System
| Score | Tier | Collateral Required |
|-------|------|---------------------|
| 800-1000 | Excellent | 110% |
| 700-799 | Good | 120% |
| 600-699 | Fair | 130% |
| 500-599 | Poor | 140% |
| 300-499 | Very Poor | 150% |

### Loan Limits
- **Min Loan**: 100 USDT
- **Max Duration**: 365 days
- **Min Duration**: 7 days
- **Liquidation Threshold**: 120%
- **Grace Period**: 3 days

## 🔧 Interacting with Contracts

### Using Cast (Command Line)

```bash
# Check USDT balance
cast call <usdt_address> "balanceOf(address)(uint256)" <your_address> \
  --rpc-url $MANTLE_SEPOLIA_RPC

# Claim from faucet
cast send <faucet_address> "claimTokens()" \
  --rpc-url $MANTLE_SEPOLIA_RPC \
  --private-key $PRIVATE_KEY

# Deposit to pool
cast send <lending_pool> "deposit(uint256)" 1000000000 \
  --rpc-url $MANTLE_SEPOLIA_RPC \
  --private-key $PRIVATE_KEY
```

### Using Ethers.js/Viem (Frontend)

```typescript
import { useWriteContract } from 'wagmi'

// Deposit to lending pool
const { writeContract } = useWriteContract()

writeContract({
  address: LENDING_POOL_ADDRESS,
  abi: LendingPoolABI,
  functionName: 'deposit',
  args: [parseUnits('1000', 6)] // 1000 USDT
})
```

## 📚 Documentation

- **Deployment Guide**: [DEPLOYMENT.md](./DEPLOYMENT.md)
- **Foundry Book**: https://book.getfoundry.sh/
- **Mantle Docs**: https://docs.mantle.xyz/
- **Contract ABIs**: Located in `out/` after build

## 🔐 Security

- **Access Control**: Ownable contracts with role-based permissions
- **Reentrancy Guards**: All external functions protected
- **Pausable**: Emergency pause functionality
- **Oracle Staleness**: 1-hour price feed checks
- **Test Coverage**: 192 comprehensive tests

### Audit Status

⚠️ **Not audited** - This is a testnet deployment for educational purposes.

## 🐛 Troubleshooting

### Common Issues

1. **"Insufficient funds"**: Ensure wallet has MNT for gas
2. **"Invalid signature"**: Check private key format in `.env`
3. **Tests failing**: Run `forge clean && forge build`
4. **Deployment fails**: Verify RPC URL and network config

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed troubleshooting.

## 📝 License

MIT License - see [LICENSE](../LICENSE)

## 🤝 Contributing

This is an educational project. Contributions, issues, and feature requests are welcome!

---

**Built with** ❤️ **using Foundry**
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

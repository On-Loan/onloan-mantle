# OnLoan Frontend

Decentralized P2P Lending Platform on Mantle Sepolia Testnet

## Tech Stack

- **Framework**: Vite + React 19 + TypeScript
- **Web3**: Wagmi v2 + RainbowKit + Viem
- **State Management**: TanStack Query (React Query)
- **Styling**: Tailwind CSS (coming in next prompts)

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Environment Configuration

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Update the following variables:

- `VITE_WALLETCONNECT_PROJECT_ID`: Get from [WalletConnect Cloud](https://cloud.walletconnect.com/)
- `VITE_USE_LOCAL_CONTRACTS`: Set to `true` for local Anvil, `false` for Mantle Sepolia
- Contract addresses: Update with your deployed contract addresses

### 3. Run Development Server

```bash
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

## Project Structure

```
frontend/
├── src/
│   ├── config/
│   │   ├── wagmi.ts              # Wagmi v2 configuration
│   │   ├── chains.ts             # Mantle Sepolia chain config
│   │   └── rainbowkit.ts         # RainbowKit purple theme
│   ├── lib/
│   │   └── contracts/
│   │       ├── addresses.ts      # Deployed contract addresses
│   │       └── abis/             # Contract ABIs (auto-generated)
│   ├── hooks/
│   │   └── useContract.ts        # Typed contract instances
│   ├── providers.tsx             # Web3 providers wrapper
│   ├── main.tsx                  # App entry with providers
│   └── App.tsx                   # Root component
├── .env                          # Environment variables
└── .env.example                  # Environment template
```

## Web3 Configuration

### Networks

- **Mantle Sepolia Testnet**
  - Chain ID: 5003
  - RPC: https://rpc.sepolia.mantle.xyz
  - Explorer: https://sepolia.mantlescan.xyz
  - Faucet: https://faucet.sepolia.mantle.xyz

### Contracts

Update `.env` with your deployed contract addresses:

```env
VITE_MOCK_USDT_ADDRESS=0x...
VITE_USDT_FAUCET_ADDRESS=0x...
VITE_INTEREST_CALCULATOR_ADDRESS=0x...
VITE_COLLATERAL_MANAGER_ADDRESS=0x...
VITE_CREDIT_SCORE_ADDRESS=0x...
VITE_LENDING_POOL_ADDRESS=0x...
VITE_LOAN_MANAGER_ADDRESS=0x...
```

### Local Development (Anvil)

For testing with local Anvil node:

1. Start Anvil in a separate terminal:
```bash
cd ../contract
anvil
```

2. Deploy contracts:
```bash
forge script script/Deploy.s.sol --fork-url http://localhost:8545 --broadcast
```

3. Set `VITE_USE_LOCAL_CONTRACTS=true` in `.env`

4. The frontend will use the local contract addresses automatically

## Usage

### Connect Wallet

1. Click "Connect Wallet" button
2. Select your wallet (MetaMask, Rainbow, etc.)
3. Switch to Mantle Sepolia network if prompted
4. Approve connection

### Available Hooks

```typescript
import { useAccount, useBalance, useReadContract, useWriteContract } from 'wagmi';
import { useContract, useContracts } from './hooks/useContract';

const { address, isConnected } = useAccount();
const { data: balance } = useBalance({ address });

const loanManager = useContract('loanManager');
const contracts = useContracts();

const { data } = useReadContract({
  ...contracts.loanManager,
  functionName: 'getUserLoans',
  args: [address],
});

const { writeContract } = useWriteContract();
writeContract({
  ...contracts.loanManager,
  functionName: 'repayLoan',
  args: [loanId, amount],
});
```

## Custom Theme

RainbowKit is configured with a custom purple theme matching the OnLoan brand:

- Primary Color: `#7c3aed` (Purple 600)
- Accent: `#a855f7` (Purple 500)
- Custom shadows and borders
- Professional clean design

## Build for Production

```bash
npm run build
```

Output will be in the `dist/` directory.

## Troubleshooting

### Wallet Not Connecting

- Ensure MetaMask is installed
- Check that you're on Mantle Sepolia network
- Try clearing browser cache and reconnecting

### Contract Read/Write Errors

- Verify contract addresses in `.env`
- Check wallet has MNT for gas fees
- Ensure contracts are deployed correctly
- Use Mantle Sepolia faucet for test MNT

### RPC Errors

- If Mantle RPC is slow, try alternative RPC endpoints
- For local development, ensure Anvil is running

## Next Steps

- **PROMPT 7**: Build UI component library (Button, Card, Input, Modal, etc.)
- **PROMPT 8**: Create layout components (Header, Sidebar, Footer)
- **PROMPT 9**: Build Dashboard page with real-time stats
- **PROMPT 10**: Implement Faucet page for test USDT claims

## Resources

- [Wagmi Docs](https://wagmi.sh/)
- [RainbowKit Docs](https://www.rainbowkit.com/)
- [Viem Docs](https://viem.sh/)
- [Mantle Docs](https://docs.mantle.xyz/)

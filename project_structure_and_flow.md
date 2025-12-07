# OnLoan - Decentralized P2P Lending Protocol

> A trustless peer-to-peer lending and borrowing platform built on Mantle Chain, enabling seamless crypto-backed loans with transparent interest rates and automated collateral management.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Design System](#design-system)
- [User Experience Philosophy](#user-experience-philosophy)
- [Project Architecture](#project-architecture)
- [Smart Contract Structure](#smart-contract-structure)
- [Setup Instructions](#setup-instructions)
- [User Flows](#user-flows)
- [Design Guidelines](#design-guidelines)
- [Development Workflow](#development-workflow)
- [Code Quality Standards](#code-quality-standards)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## 🎯 Overview

**OnLoan** is a decentralized peer-to-peer lending protocol that eliminates intermediaries by connecting lenders and borrowers directly on the Mantle Chain testnet. Built with a focus on transparency, security, and user experience, OnLoan enables:

- **For Lenders**: Deposit stablecoins (USDT) into lending pools and earn competitive APY through automated interest distribution
- **For Borrowers**: Access instant liquidity by providing ETH or USDT collateral with flexible loan terms and transparent interest rates
- **Pool-Based Efficiency**: Instant matching through liquidity pools eliminates waiting times and maximizes capital efficiency
- **Credit Score System**: On-chain reputation building through successful loan repayments, unlocking better terms over time
- **Auto-Liquidation**: Chainlink price oracles ensure fair, automated collateral liquidation protecting both parties

**Core Value Proposition**: OnLoan combines the capital efficiency of traditional lending with the transparency and security of DeFi, all built on Mantle's low-cost, high-performance infrastructure.

---

## ✨ Features

### For Lenders
- **Pool Deposits**: Contribute USDT to lending pools with single-click deposits
- **Passive Income**: Earn competitive APY (5-10%) based on pool utilization
- **Real-Time Analytics**: Track total deposits, accrued interest, and pool performance
- **Flexible Withdrawals**: Withdraw available liquidity anytime with instant settlement
- **Risk Transparency**: View total active loans, collateral ratios, and liquidation history

### For Borrowers
- **Instant Loans**: Borrow USDT against ETH or USDT collateral with instant approval
- **Loan Types**: Choose from Personal (8%), Home (5%), Business (10%), or Auto (6%) loans
- **Flexible Terms**: Select loan duration from 30 days to 365 days
- **Dual Collateral**: Use either ETH or USDT as collateral based on your preference
- **Partial Repayments**: Make repayments anytime with real-time interest calculation
- **Credit Building**: Build on-chain credit score to unlock lower collateral requirements

### Platform Features
- **Transaction History** `<Receipt />`: Complete audit trail of all deposits, loans, repayments, and withdrawals
- **Credit Score Dashboard** `<Shield />`: Visualize credit score progression and unlock new tiers
- **Pool Overview** `<Waves />`: Real-time pool statistics including TVL, utilization rate, and APY
- **Liquidation Monitor** `<AlertTriangle />`: Track collateral health and receive early warnings
- **Multi-Loan Support** `<FileText />`: Manage multiple active loans simultaneously
- **Gas Optimization** `<Zap />`: Benefit from Mantle's low transaction costs

---

## 🛠 Technology Stack

### Frontend Framework
- **Next.js 14** with App Router (Recommended for Mantle optimization)
  - Server Components for optimal performance
  - Built-in routing and API routes
  - Image optimization and SEO
  - Edge runtime support for global CDN delivery
  
  *Alternative: React 18 + Vite for lighter, faster builds on Mantle's low-cost infrastructure*

### Styling & Design (Professional Modern Approach)
- **Tailwind CSS v4** - Utility-first with custom design tokens
- **CSS Variables** - Dynamic theming system
- **Framer Motion** - Smooth, purposeful animations
- **Recharts** - Professional data visualization
- **Lucide React** - 1000+ consistent, customizable SVG icons
- **Custom Components** - Purpose-built UI elements from scratch

### Icon System
- **Library**: Lucide React (`lucide-react` package)
- **Style**: Outlined, 24px default size, 2px stroke width
- **Usage**: Import individual icons for tree-shaking
- **Customization**: Size, color, and stroke via props
- **Consistency**: Use same icon family throughout application

### Web3 Integration
- **Wagmi v2** - React Hooks for Ethereum
- **Viem** - TypeScript-first Ethereum library (modern alternative to ethers.js)
- **RainbowKit** or **ConnectKit** - Wallet connection UI with AppKit styling
- **Mantle Network** - Layer 2 deployment (Testnet: `rpc.sepolia.mantle.xyz`)

### State Management
- **Zustand** - Lightweight state management for UI state
- **TanStack Query (React Query)** - Server state and caching for contract data

### Data Visualization
- **Recharts** or **Chart.js** - APY trends, loan analytics, credit score charts

### Smart Contracts
- **Solidity 0.8.20+** - Contract language
- **Foundry** - Development framework (forge, cast, anvil)
- **OpenZeppelin Contracts** - Security standards (Ownable, ReentrancyGuard, Pausable)
- **Chainlink Oracles** - Price feeds for ETH/USD

### Development Tools
- **TypeScript 5+** - Type safety across frontend and contracts
- **ESLint + Prettier** - Code formatting and linting
- **Husky** - Git hooks for code quality
- **pnpm** or **yarn** - Package management

---

## 🎨 Design System

### Visual Identity
OnLoan embodies **professional DeFi design** - clean, modern, and purposeful. Built for Mantle's high-performance infrastructure, the interface prioritizes clarity, usability, and trustworthiness.

#### Core Principles
1. **Clarity & Hierarchy**: Bold typography with clear information architecture
2. **Functional Design**: Every element serves a purpose - no decorative clutter
3. **Intentional Interactions**: User-initiated actions only; no auto-popups or surprises
4. **Smooth Transitions**: Purposeful animations that enhance usability
5. **Professional Aesthetics**: Clean, trustworthy interface optimized for financial operations
6. **Custom Components**: Purpose-built elements tailored to lending operations

### Color Palette

```css
/* Primary Purple - Financial Innovation & Trust */
--primary-light: #A78BFA;    /* Hover states, backgrounds */
--primary: #8B5CF6;           /* Primary CTAs, links, focus */
--primary-dark: #7C3AED;      /* Active states, pressed buttons */

/* Accent Yellow - Highlights & Warnings */
--accent: #FBBF24;            /* Success states, highlights */
--accent-light: #FDE68A;      /* Warning backgrounds */

/* Neutrals - White Background System */
--white: #FFFFFF;             /* Pure white backgrounds */
--gray-50: #F9FAFB;           /* Subtle backgrounds, cards */
--gray-100: #F3F4F6;          /* Disabled states, borders */
--gray-200: #E5E7EB;          /* Dividers, input borders */
--gray-400: #9CA3AF;          /* Placeholder text */
--gray-600: #4B5563;          /* Secondary text */
--gray-900: #111827;          /* Primary text, headings */

/* Semantic Colors */
--success: #10B981;           /* Successful transactions */
--error: #EF4444;             /* Errors, liquidation warnings */
--warning: #F59E0B;           /* Caution states */
```

#### Usage Guidelines
- **Backgrounds**: White (#FFFFFF) for main pages, Gray-50 (#F9FAFB) for cards
- **Text**: Gray-900 for headings, Gray-600 for body, Gray-400 for hints
- **CTAs**: Primary purple (#8B5CF6) for main actions, outline variants for secondary
- **Particles**: Primary purple at 40% opacity with subtle glow effects
### Typography (Bold & Modern)

```css
/* Font Family - Premium Variable Fonts */
--font-display: 'Space Grotesk', system-ui, sans-serif;  /* Bold headlines */
--font-body: 'Inter Variable', -apple-system, sans-serif;  /* Body text */
--font-mono: 'JetBrains Mono', 'Fira Code', monospace;   /* Numbers, addresses */

/* Heading Scale - BOLD sizes for impact */
--h1: clamp(56px, 8vw, 96px) / 0.95 / 800;    /* Hero headlines - Massive */
--h2: clamp(40px, 6vw, 72px) / 1.0 / 800;     /* Section titles */
--h3: clamp(32px, 4vw, 56px) / 1.1 / 700;     /* Card headers */
--h4: clamp(24px, 3vw, 36px) / 1.2 / 700;     /* Subsections */
--h5: 20px / 1.3 / 600;                        /* Table headers */

/* Body Scale - Larger for readability */
--body-xl: 22px / 1.7 / 400;   /* Featured content */
--body-lg: 18px / 1.6 / 400;   /* Primary content */
--body: 16px / 1.5 / 400;      /* Default text */
--body-sm: 14px / 1.5 / 500;   /* Secondary info */
--caption: 12px / 1.4 / 600;   /* Labels, uppercase tracking */

/* Special Styles */
--mono-lg: 20px / 1.4 / 500;   /* Large numbers (APY, amounts) */
--mono: 16px / 1.4 / 500;      /* Wallet addresses, tx hashes */

/* Letter Spacing */
--tracking-tight: -0.02em;     /* Large headlines */
--tracking-normal: 0;
--tracking-wide: 0.05em;       /* Uppercase labels */
```ody-sm: 14px / 1.5 / 400;   /* Secondary info */
--caption: 12px / 1.4 / 500;   /* Labels, captions */
```

### Spacing System
```css
### Component Patterns (Modern & Custom)

#### Buttons - Physics-Based Interactions
```typescript
// Primary Action Button - Clean & Professional
import { Wallet } from 'lucide-react';

<motion.button
  className="
    bg-primary hover:bg-primary-dark
    text-white font-bold
    px-8 py-4 rounded-2xl
    text-lg tracking-tight
    transition-colors duration-200
    flex items-center gap-2
  "
  whileHover={{ scale: 1.02 }}
  whileTap={{ scale: 0.98 }}
  transition={{ duration: 0.2 }}
>
  <Wallet className="w-5 h-5" />
  Connect Wallet
</motion.button>

// Secondary Button - Outline Style
<button className="
  bg-white border-2 border-primary 
  text-primary hover:bg-primary hover:text-white
  font-semibold
  px-8 py-4 rounded-2xl
  transition-all duration-200
">
  View Details
</button>

// Minimal Ghost Button with Underline Animation
<button className="
  group relative
#### Cards - Clean Professional Design
```typescript
// Standard Card
<div
  className="
    bg-white rounded-2xl
    p-8 lg:p-10
    border border-gray-200
    hover:border-gray-300
    transition-colors duration-200
  "
>
  {/* Card content */}
</div>

// Elevated Card - Subtle Depth
<div className="
  bg-white rounded-2xl
  p-8
  border border-gray-200
  shadow-sm hover:shadow-md
  transition-shadow duration-200
">
  {/* Card content */}
</div>

// Stat Card - Bold Numbers
<div className="
  bg-gradient-to-br from-gray-900 to-gray-800
  text-white rounded-3xl p-8
  relative overflow-hidden
  group cursor-pointer
#### Input Fields - Premium Interactions
```typescript
// Modern Input with Floating Label
<div className="relative group">
  <input
    type="text"
    id="amount"
    className="
      peer w-full px-6 py-5
      bg-gray-50 border-2 border-transparent
      rounded-2xl
      text-lg font-semibold text-gray-900
      placeholder-transparent
      focus:bg-white focus:border-primary
      transition-all duration-200
      outline-none
    "
    placeholder="0.00"
  />
  <label
    htmlFor="amount"
    className="
      absolute left-6 -top-3
      px-2 bg-white
      text-sm font-semibold text-gray-600
      peer-placeholder-shown:text-lg peer-placeholder-shown:top-5 peer-placeholder-shown:text-gray-400
      peer-focus:-top-3 peer-focus:text-sm peer-focus:text-primary
      transition-all duration-200
      pointer-events-none
    "
  >
    Enter Amount
  </label>
  
  {/* Max button */}
  <button className="
    absolute right-3 top-1/2 -translate-y-1/2
    px-4 py-2 rounded-xl
    bg-primary/10 hover:bg-primary/20
    text-primary font-bold text-sm
    transition-colors
  ">
    MAX
  </button>
</div>

// Token Input with Selection
<div className="
  relative flex items-center gap-4
  bg-white border-2 border-gray-200
  rounded-2xl px-6 py-5
  focus-within:border-primary
  transition-colors duration-200
">
  <input
    type="number"
    className="
      flex-1 bg-transparent
      text-3xl font-bold font-mono text-gray-900
      placeholder:text-gray-300
      outline-none
    "
    placeholder="0.0"
  />
  
  <button className="
    flex items-center gap-2 shrink-0
    bg-gray-100 hover:bg-gray-200
    px-4 py-3 rounded-xl
    transition-colors
  ">
    <img src="/usdt.svg" className="w-6 h-6" />
    <span className="font-bold text-gray-900">USDT</span>
    <ChevronDownIcon className="w-5 h-5 text-gray-600" />
  </button>
</div>

// Range Slider - Custom Styled
<div className="space-y-4">
  <label className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
    Loan Duration
  </label>
  <input
    type="range"
    min="30"
    max="365"
    className="
      w-full h-3 rounded-full appearance-none cursor-pointer
      bg-gradient-to-r from-primary/20 to-primary/40
      [&::-webkit-slider-thumb]:appearance-none
### Animation Principles (Premium Motion Design)

#### Framer Motion - Physics-Based Animations
```typescript
// Page Transitions - Smooth & Sophisticated
const pageVariants = {
  initial: { 
    opacity: 0, 
    y: 60,
    scale: 0.95
  },
  animate: { 
    opacity: 1, 
    y: 0,
    scale: 1,
    transition: { 
      duration: 0.6,
      ease: [0.43, 0.13, 0.23, 0.96], // Custom easing
      staggerChildren: 0.1
    } 
  },
  exit: { 
    opacity: 0, 
    y: -60,
#### Hero Section - Clean & Professional
```typescript
// Simple Gradient Background
function HeroBackground() {
  return (
    <div className="
      absolute inset-0 -z-10
      bg-gradient-to-br from-gray-50 via-white to-primary/5
    " />
  );
}

// Optional: Subtle Grid Pattern (CSS only)
<div className="
  absolute inset-0 -z-10
  bg-[linear-gradient(to_right,#e5e7eb_1px,transparent_1px),linear-gradient(to_bottom,#e5e7eb_1px,transparent_1px)]
  bg-[size:4rem_4rem]
  [mask-image:radial-gradient(ellipse_80%_50%_at_50%_0%,#000_70%,transparent_110%)]
" />
```idden: { opacity: 0, y: 40, scale: 0.95 },
  show: { 
    opacity: 1, 
    y: 0, 
    scale: 1,
    transition: {
      type: "spring",
      stiffness: 260,
      damping: 20
    }
  }
};

// Magnetic Button - Follows cursor
function MagneticButton({ children }) {
  const ref = useRef(null);
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleMouse = (e) => {
    const { clientX, clientY } = e;
    const { left, top, width, height } = ref.current.getBoundingClientRect();
    const x = (clientX - (left + width / 2)) * 0.3;
    const y = (clientY - (top + height / 2)) * 0.3;
    setPosition({ x, y });
  };

  return (
    <motion.button
      ref={ref}
      onMouseMove={handleMouse}
      onMouseLeave={() => setPosition({ x: 0, y: 0 })}
      animate={{ x: position.x, y: position.y }}
      transition={{ type: "spring", stiffness: 150, damping: 15 }}
    >
      {children}
    </motion.button>
  );
}

// Number Counter Animation
function AnimatedNumber({ value, duration = 2 }) {
  const nodeRef = useRef();
  
  useEffect(() => {
    const node = nodeRef.current;
    const controls = animate(0, value, {
      duration,
      onUpdate(value) {
        node.textContent = value.toFixed(2);
      }
    });
    return () => controls.stop();
  }, [value]);

  return <span ref={nodeRef} />;
}

// Reveal on Scroll - GSAP ScrollTrigger
useEffect(() => {
  gsap.fromTo(
    ".stat-card",
    { opacity: 0, y: 100, scale: 0.9 },
    {
      opacity: 1,
      y: 0,
      scale: 1,
      duration: 0.8,
      stagger: 0.15,
      ease: "power3.out",
      scrollTrigger: {
        trigger: ".stats-section",
        start: "top 80%",
        end: "bottom 20%",
        toggleActions: "play none none reverse"
      }
    }
  );
}, []);
```   <TrendUpIcon className="w-4 h-4" />
      +24.5% this month
    </p>
  </div>
  
  {/* Glow orb */}
  <div className="
    absolute -right-12 -bottom-12 w-48 h-48
    bg-primary/30 rounded-full blur-3xl
  " />
</div>
```
// Icon Button - Floating with tooltip
<motion.button
  className="
    relative
    w-14 h-14 rounded-full
    bg-gradient-to-br from-primary to-primary-dark
    text-white flex items-center justify-center
    shadow-lg hover:shadow-2xl
    transition-shadow duration-300
  "
  whileHover={{ rotate: 90, scale: 1.1 }}
  whileTap={{ scale: 0.9 }}
>
  <PlusIcon className="w-6 h-6" />
  <span className="
    absolute -top-12 left-1/2 -translate-x-1/2
    px-3 py-1.5 rounded-lg
    bg-gray-900 text-white text-sm
    opacity-0 group-hover:opacity-100
    transition-opacity pointer-events-none
    whitespace-nowrap
  ">
    Add Collateral
  </span>
</motion.button>
```iew Details
</button>

// Ghost Button
<button className="
  text-primary hover:bg-primary/10
  font-medium px-4 py-2 rounded-lg
  transition-colors duration-150
">
  Learn More
</button>
```

#### Cards
```typescript
<div className="
  bg-white rounded-2xl
  p-6 lg:p-8
  border border-gray-200
  shadow-sm hover:shadow-md
  transition-shadow duration-300
">
  {/* Card content */}
</div>
```

#### Input Fields
```typescript
<input className="
  w-full px-4 py-3
  border border-gray-200 rounded-xl
  focus:border-primary focus:ring-4 focus:ring-primary/20
  transition-all duration-200
  text-gray-900 placeholder:text-gray-400
"/>
```

### Animation Principles

#### Framer Motion Variants
```typescript
// Page Transitions
const pageVariants = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0, transition: { duration: 0.4 } },
  exit: { opacity: 0, y: -20, transition: { duration: 0.3 } }
};

// Card Hover
const cardHover = {
  rest: { scale: 1 },
  hover: { scale: 1.02, transition: { duration: 0.2 } }
};

// Button Click
const buttonTap = {
  scale: 0.95,
  transition: { duration: 0.1 }
};
```

#### Particle Configuration
```typescript
// Hero Section Particles (tsparticles)
const particleConfig = {
  particles: {
    number: { value: 50, density: { enable: true, value_area: 800 } },
    color: { value: "#8B5CF6" },
    opacity: { value: 0.4, random: true },
    size: { value: 3, random: true },
    line_linked: {
      enable: true,
      color: "#8B5CF6",
      opacity: 0.2,
      width: 1
    },
    move: { speed: 1, direction: "none", out_mode: "bounce" }
  }
};
```

---

## 🧭 User Experience Philosophy

### Core Principles

#### 1. Intentional Interactions Only
- **No Auto-Popups**: All modals, dialogs, and overlays triggered by user clicks
- **Clear CTAs**: Every action button clearly states what will happen
- **Confirmations**: High-value transactions (deposits, loans) require explicit confirmation
- **Dismissible**: All notifications can be dismissed by user

#### 2. Progressive Disclosure
- **Dashboard Overview**: High-level metrics visible immediately
- **Details on Demand**: Click to expand loan details, transaction history
- **Step-by-Step Forms**: Multi-step loan/deposit forms with clear progress
- **Tooltips**: Hover for explanations of complex terms (APY, collateral ratio)

#### 3. Navigation Structure

```
Sidebar Navigation (Desktop) | Bottom Nav (Mobile)
├─ <LayoutDashboard />  Dashboard       - Portfolio overview, quick stats
├─ <Coins />            Lend            - Deposit to pool, view earnings
├─ <HandCoins />        Borrow          - Request loan, view available liquidity
├─ <FileText />         My Loans        - Active loans, repayment schedule
├─ <Waves />            Pool Overview   - TVL, utilization, APY trends
├─ <Droplets />         Faucet          - Claim 1000 USDT every 24h (Testnet only)
├─ <Receipt />          Transactions    - Complete history with filters
└─ <User />             Profile         - Wallet info, credit score, settings
```

#### 4. Feedback & Validation

```typescript
// Loading States
<Button disabled={isLoading}>
  {isLoading ? <Spinner /> : 'Deposit USDT'}
</Button>

// Success Notifications (Toast)
toast.success('Deposit successful! 1,000 USDT added to pool', {
  action: { label: 'View Transaction', onClick: () => {} }
});

// Error Messages (Inline)
{error && (
  <div className="text-error text-sm mt-2 flex items-center gap-2">
    <AlertIcon /> {error.message}
  </div>
)}

// Form Validation (Real-time)
<Input
  error={amount > balance}
  helperText={amount > balance ? 'Insufficient balance' : ''}
/>
```

#### 5. Wallet Connection Flow
```
1. Click "Connect Wallet" (top-right, always visible)
   ↓
2. RainbowKit modal opens with wallet options
   ↓
3. User selects wallet (MetaMask, WalletConnect, etc.)
   ↓
4. Wallet prompts for connection approval
   ↓
5. Success: Button shows address (0x1234...5678)
   ↓
6. Click address → Dropdown menu (Switch Network, Disconnect)
```

#### 6. Transaction Flow Pattern
```
Every blockchain transaction follows:
1. User Action → Button click
2. Input Validation → Show errors if invalid
3. Simulation (optional) → Preview outcome
4. Wallet Prompt → User signs transaction
5. Pending State → Show loading with tx hash link
6. Confirmation → Success toast + UI update
7. Error Handling → Clear message + retry option
```

---

## 🏗 Project Architecture

### Directory Structure

```
onloan-mantle/
├── contract/                    # Smart contracts (Foundry)
│   ├── src/
│   │   ├── LendingPool.sol     # Pool management (deposits, withdrawals)
│   │   ├── LoanManager.sol     # Loan lifecycle (create, repay, liquidate)
│   │   ├── InterestCalculator.sol  # Interest rate logic
│   │   ├── CollateralManager.sol   # Collateral tracking & liquidation
│   │   ├── MockUSDT.sol        # Test USDT token for Mantle testnet
│   │   ├── USDTFaucet.sol      # 24-hour claim faucet (1000 USDT)
│   │   └── interfaces/
│   │       ├── ILendingPool.sol
│   │       ├── ILoanManager.sol
│   │       ├── IPriceOracle.sol
│   │       └── IERC20.sol
│   ├── test/
│   │   ├── LendingPool.t.sol   # Unit tests
│   │   ├── LoanManager.t.sol
│   │   ├── CollateralManager.t.sol
│   │   ├── Faucet.t.sol        # Faucet claim tests
│   │   ├── Integration.t.sol    # Full lifecycle tests
│   │   └── Invariants.t.sol     # Fuzzing & invariants
│   ├── script/
│   │   ├── Deploy.s.sol         # Main deployment script
│   │   ├── DeployMocks.s.sol    # Deploy MockUSDT and Faucet
│   │   └── Interactions.s.sol   # Helper interaction scripts
│   ├── foundry.toml
│   └── remappings.txt
│
├── frontend/                    # Next.js 14 App Router
│   ├── src/
│   │   ├── app/                 # App Router pages
│   │   │   ├── layout.tsx       # Root layout with providers
│   │   │   ├── page.tsx         # Home/Landing page
│   │   │   ├── dashboard/
│   │   │   │   └── page.tsx
│   │   │   ├── lend/
│   │   │   │   └── page.tsx
│   │   │   ├── borrow/
│   │   │   │   └── page.tsx
│   │   │   ├── loans/
│   │   │   │   └── page.tsx
│   │   │   ├── pool/
│   │   │   │   └── page.tsx
│   │   │   ├── faucet/
│   │   │   │   └── page.tsx
│   │   │   ├── transactions/
│   │   │   │   └── page.tsx
│   │   │   └── profile/
│   │   │       └── page.tsx
│   │   │
│   │   ├── components/          # Reusable components (max 300 lines)
│   │   │   ├── layout/
│   │   │   │   ├── Header.tsx   # Top navbar with wallet
│   │   │   │   ├── Sidebar.tsx  # Desktop sidebar nav
│   │   │   │   ├── BottomNav.tsx # Mobile navigation
│   │   │   │   └── Footer.tsx
│   │   │   ├── ui/              # Base UI components
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Card.tsx
│   │   │   │   ├── Input.tsx
│   │   │   │   ├── Modal.tsx
│   │   │   │   ├── Toast.tsx
│   │   │   │   └── Spinner.tsx
│   │   │   ├── wallet/
│   │   │   │   ├── ConnectButton.tsx
│   │   │   │   └── WalletInfo.tsx
│   │   │   └── particles/
│   │   │       └── HeroParticles.tsx
│   │   │
│   │   ├── features/            # Feature-specific components (max 400 lines)
│   │   │   ├── lending/
│   │   │   │   ├── DepositForm.tsx
│   │   │   │   ├── WithdrawForm.tsx
│   │   │   │   ├── LenderStats.tsx
│   │   │   │   └── EarningsChart.tsx
│   │   │   ├── borrowing/
│   │   │   │   ├── LoanRequestForm.tsx
│   │   │   │   ├── LoanTypeSelector.tsx
│   │   │   │   ├── CollateralInput.tsx
│   │   │   │   └── LoanCalculator.tsx
│   │   │   ├── loans/
│   │   │   │   ├── LoanCard.tsx
│   │   │   │   ├── RepaymentForm.tsx
│   │   │   │   └── LoanTimeline.tsx
│   │   │   ├── pool/
│   │   │   │   ├── PoolStats.tsx
│   │   │   │   ├── UtilizationChart.tsx
│   │   │   │   └── LiquidityMetrics.tsx
│   │   │   ├── credit/
│   │   │   │   ├── CreditScoreGauge.tsx
│   │   │   │   ├── ScoreHistory.tsx
│   │   │   │   └── TierBenefits.tsx
│   │   │   ├── faucet/
│   │   │   │   ├── ClaimCard.tsx
│   │   │   │   ├── ClaimTimer.tsx
│   │   │   │   ├── ClaimHistory.tsx
│   │   │   │   └── FaucetStats.tsx
│   │   │   └── transactions/
│   │   │       ├── TransactionList.tsx
│   │   │       ├── TransactionFilters.tsx
│   │   │       └── TransactionDetails.tsx
│   │   │
│   │   ├── hooks/               # Custom React hooks (max 200 lines)
│   │   │   ├── useContract.ts   # Contract instance hook
│   │   │   ├── useLendingPool.ts
│   │   │   ├── useLoans.ts
│   │   │   ├── useUserBalance.ts
│   │   │   ├── useCreditScore.ts
│   │   │   ├── useFaucet.ts     # Faucet claim logic
│   │   │   ├── useTransactions.ts
│   │   │   └── useNotification.ts
│   │   │
│   │   ├── lib/                 # Utilities & helpers (max 300 lines)
│   │   │   ├── contracts/
│   │   │   │   ├── abis/        # Contract ABIs (auto-generated)
│   │   │   │   ├── addresses.ts # Contract addresses by network
│   │   │   │   └── clients.ts   # Viem clients setup
│   │   │   ├── utils/
│   │   │   │   ├── format.ts    # Number/date formatting
│   │   │   │   ├── validation.ts
│   │   │   │   └── calculations.ts  # Interest, collateral calcs
│   │   │   └── constants.ts
│   │   │
│   │   ├── config/              # Configuration files
│   │   │   ├── wagmi.ts         # Wagmi config
│   │   │   ├── chains.ts        # Mantle chain config
│   │   │   └── rainbowkit.ts    # RainbowKit theme
│   │   │
│   │   ├── types/               # TypeScript types
│   │   │   ├── contracts.ts     # Contract types
│   │   │   ├── loan.ts
│   │   │   ├── pool.ts
│   │   │   └── user.ts
│   │   │
│   │   └── styles/
│   │       └── globals.css      # Tailwind imports + custom styles
│   │
│   ├── public/
│   │   ├── images/
│   │   └── icons/
│   ├── package.json
│   ├── tsconfig.json
│   ├── tailwind.config.ts       # Purple theme config
│   ├── next.config.js
│   └── .env.example
│
├── .github/
│   └── workflows/
│       ├── test.yml             # Run contract tests
│       └── deploy.yml           # Deploy to testnet
│
├── README.md                    # This file
└── .gitignore
```

### File Size Limits
- **Components**: Max 300 lines
- **Features**: Max 400 lines
- **Hooks**: Max 200 lines
- **Utils**: Max 300 lines
- **Pages**: Max 500 lines (prefer composition)

### Component Composition Pattern
```typescript
// ❌ Bad: Monolithic component (800 lines)
export function LoanPage() {
  // Too much logic in one file
}

// ✅ Good: Composed from smaller components
export function LoanPage() {
  return (
    <PageLayout>
      <LoanFilters />      {/* 50 lines */}
      <LoanList />         {/* 100 lines */}
      <LoanDetails />      {/* 150 lines */}
    </PageLayout>
  );
}
```

---

## 📜 Smart Contract Structure

### Contract Modules

#### 1. LendingPool.sol (Core Pool Management)
```solidity
// Responsibilities:
- Accept USDT deposits from lenders
- Track individual lender balances
- Calculate and distribute interest to lenders
- Handle withdrawals with liquidity checks
- Maintain total pool liquidity state

// Key Functions:
function deposit(uint256 amount) external
function withdraw(uint256 amount) external
function getAvailableLiquidity() external view returns (uint256)
function calculateLenderInterest(address lender) external view returns (uint256)
function claimInterest() external

// State Variables:
mapping(address => Deposit) public deposits;
uint256 public totalLiquidity;
uint256 public totalBorrowed;
```

#### 2. LoanManager.sol (Loan Lifecycle)
```solidity
// Responsibilities:
- Create new loans with collateral validation
- Track active loans per user
- Process repayments and interest calculation
- Handle loan completion and collateral return
- Emit events for frontend updates

// Key Functions:
function createLoan(uint256 amount, uint256 duration, LoanType loanType, bool useETH) external payable
function repay(uint256 loanId, uint256 amount) external
function getLoanDetails(uint256 loanId) external view returns (Loan memory)
function getUserLoans(address borrower) external view returns (uint256[] memory)
function calculateDueAmount(uint256 loanId) external view returns (uint256)

// State Variables:
mapping(uint256 => Loan) public loans;
mapping(address => uint256[]) public userLoanIds;
uint256 public nextLoanId;
```

#### 3. CollateralManager.sol (Collateral & Liquidation)
```solidity
// Responsibilities:
- Accept and lock collateral (ETH or USDT)
- Monitor collateral health using Chainlink ETH/USD price oracles
- Calculate real-time collateral value in USD
- Trigger liquidations when collateral value drops below threshold
- Distribute liquidation rewards to liquidators (5% incentive)
- Return collateral on successful repayment
- Recover protocol funds from seized collateral

// Key Functions:
function lockCollateral(uint256 loanId, uint256 amount, bool isETH) external payable
function checkCollateralHealth(uint256 loanId) external view returns (uint256)
function getCollateralValueUSD(uint256 loanId) external view returns (uint256)
function liquidate(uint256 loanId) external // Public liquidation with rewards
function releaseCollateral(uint256 loanId) internal
function getRequiredCollateral(uint256 loanAmount, uint16 ratio) external view returns (uint256)
function getETHPrice() public view returns (uint256) // From Chainlink oracle

// State Variables:
mapping(uint256 => Collateral) public collaterals;
AggregatorV3Interface public ethUsdPriceFeed;  // Chainlink ETH/USD price feed
uint16 public constant LIQUIDATION_THRESHOLD = 120;  // 120% - liquidate below this
uint16 public constant LIQUIDATION_BONUS = 500;     // 5% bonus for liquidators
uint256 public constant PRICE_STALENESS_THRESHOLD = 3600; // 1 hour max

// Liquidation Flow:
1. Monitor: Check if (collateralValueUSD / loanAmount) < 120%
2. Anyone can call liquidate() when threshold breached
3. Protocol seizes collateral to cover loan amount
4. Liquidator receives 5% bonus from seized collateral
5. Remaining collateral (if any) returned to protocol reserve
6. Loan marked as defaulted, credit score penalized

// Price Oracle Safety:
- Verify price feed timestamp is recent (< 1 hour old)
- Revert if oracle returns invalid data (0 or negative)
- Use 8-decimal price format from Chainlink
- Convert all amounts to consistent decimals for comparison
```

#### 4. InterestCalculator.sol (Interest Logic)
```solidity
// Responsibilities:
- Calculate borrow interest rates based on utilization
- Determine lender APY distribution
- Apply different rates for loan types
- Handle compound vs simple interest

// Key Functions:
function calculateBorrowRate(uint256 utilization) external pure returns (uint256)
function calculateLenderAPY(uint256 totalInterest, uint256 poolSize) external pure returns (uint256)
function getInterestRateByType(LoanType loanType) external pure returns (uint256)
function calculateAccruedInterest(uint256 principal, uint256 rate, uint256 duration) external pure returns (uint256)

// Constants:
uint256 public constant BASE_RATE = 300; // 3%
uint256 public constant OPTIMAL_UTILIZATION = 8000; // 80%
```

#### 5. CreditScore.sol (Reputation System)
```solidity
// Responsibilities:
- Track user credit scores (0-1000)
- Update scores based on repayment history
- Calculate dynamic collateral requirements
- Store loan history and default records

// Key Functions:
function updateScore(address user, bool successful) external
function getCreditScore(address user) external view returns (uint256)
function getCollateralRatio(address user) external view returns (uint16)
function getBorrowLimit(address user) external view returns (uint256)

// State Variables:
mapping(address => CreditProfile) public profiles;
```

#### 6. MockUSDT.sol (Test Token)
```solidity
// Responsibilities:
- ERC20 token with 6 decimals (matches real USDT)
- Mintable for testing purposes on Mantle testnet
- Used by faucet and lending protocol

// Key Functions:
function mint(address to, uint256 amount) external onlyOwner
function decimals() public pure returns (uint8) // Returns 6

// Deployment:
- Only deployed on Mantle Sepolia testnet
- Owner can mint for faucet distribution
- Standard ERC20 implementation from OpenZeppelin
```

#### 7. USDTFaucet.sol (Testing Faucet)
```solidity
// Responsibilities:
- Distribute 1000 USDT per user every 24 hours
- Prevent abuse with time-based restrictions
- Track last claim timestamp per address
- Enable users to test the lending platform

// Key Functions:
function claimTokens() external returns (bool)
function getNextClaimTime(address user) external view returns (uint256)
function canClaim(address user) external view returns (bool)
function getClaimAmount() external pure returns (uint256) // 1000 USDT

// State Variables:
mapping(address => uint256) public lastClaimTime;
IERC20 public usdtToken;
uint256 public constant CLAIM_AMOUNT = 1000 * 10**6;  // 1000 USDT (6 decimals)
uint256 public constant CLAIM_INTERVAL = 24 hours;

// Security:
- Check sufficient faucet balance before distribution
- Emit events for all claims
- Owner can refill faucet with MockUSDT
```

### Contract Interaction Flow
```
User (Frontend)
    ↓
1. Deposit USDT → LendingPool.deposit()
    ↓
2. Request Loan → LoanManager.createLoan()
    ↓ (calls)
CollateralManager.lockCollateral()  &  InterestCalculator.calculateRate()
    ↓
3. LendingPool transfers USDT to borrower
    ↓
4. Repay → LoanManager.repay()
    ↓
CollateralManager.releaseCollateral()  &  CreditScore.updateScore()
    ↓
5. Interest distributed → LendingPool.calculateLenderInterest()
```

### Security Features
- **OpenZeppelin**: ReentrancyGuard, Ownable, Pausable
- **Access Control**: Role-based permissions for admin functions
- **Oracle Safety**: Staleness checks on Chainlink price feeds with fallback mechanisms
- **Emergency Pause**: Circuit breaker for critical issues
- **Price Monitoring**: Real-time collateral value tracking for liquidation triggers
- **Non-Upgradeable**: Immutable contracts deployed directly (no proxy pattern)

---

## 🚀 Setup Instructions

### Prerequisites
- **Node.js**: v18+ (LTS recommended)
- **Package Manager**: pnpm (preferred), yarn, or npm
- **Foundry**: Latest version for smart contracts
- **Git**: For version control
- **Wallet**: MetaMask or compatible wallet with Mantle testnet configured

### Installation Steps

#### 1. Clone Repository
```bash
git clone https://github.com/On-Loan/onloan-mantle.git
cd onloan-mantle
```

#### 2. Install Smart Contract Dependencies
```bash
cd contract
forge install OpenZeppelin/openzeppelin-contracts
forge install smartcontractkit/chainlink
forge build

# Create remappings
echo "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/" > remappings.txt
echo "@chainlink/contracts/=lib/chainlink/contracts/" >> remappings.txt
```

#### 3. Install Frontend Dependencies
```bash
cd ../frontend
pnpm install
# or: npm install / yarn install

# Ensure lucide-react is installed
pnpm add lucide-react
# or: npm install lucide-react
```

#### 4. Configure Environment Variables

Create `.env.local` in frontend directory:
```env
# Mantle Testnet Configuration
NEXT_PUBLIC_MANTLE_RPC_URL=https://rpc.sepolia.mantle.xyz
NEXT_PUBLIC_CHAIN_ID=5003

# Contract Addresses (after deployment)
NEXT_PUBLIC_LENDING_POOL_ADDRESS=0x...
NEXT_PUBLIC_LOAN_MANAGER_ADDRESS=0x...
NEXT_PUBLIC_COLLATERAL_MANAGER_ADDRESS=0x...
NEXT_PUBLIC_MOCK_USDT_ADDRESS=0x...
NEXT_PUBLIC_FAUCET_ADDRESS=0x...

# WalletConnect Project ID (get from cloud.walletconnect.com)
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id

# Optional: Analytics
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX
```

Create `.env` in contract directory:
```env
# Mantle Testnet
MANTLE_RPC_URL=https://rpc.sepolia.mantle.xyz
PRIVATE_KEY=your_private_key_here

# Mantle Mainnet (for production)
MANTLE_MAINNET_RPC_URL=https://rpc.mantle.xyz

# Etherscan API for verification
ETHERSCAN_API_KEY=your_api_key
```

#### 5. Add Mantle Testnet to Wallet

**Network Details:**
```
Network Name: Mantle Sepolia Testnet
RPC URL: https://rpc.sepolia.mantle.xyz
Chain ID: 5003
Currency Symbol: MNT
Block Explorer: https://explorer.sepolia.mantle.xyz
```

**Get Testnet Tokens:**
- MNT Faucet: [Mantle Faucet](https://faucet.sepolia.mantle.xyz)
- USDT Testnet: Deploy mock USDT or use existing testnet USDT

### Local Development

#### Run Frontend Development Server
```bash
cd frontend
pnpm dev
# Opens at http://localhost:3000
```

#### Run Local Blockchain (Anvil)
```bash
cd contract
anvil --chain-id 5003
# Local chain at http://localhost:8545
```

#### Deploy Contracts to Local Anvil
```bash
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

#### Deploy Contracts to Mantle Testnet
```bash
forge script script/Deploy.s.sol \
#### Stat Card - Professional Design
```typescript
import { TrendingUp, ArrowUp } from 'lucide-react';

<div
  className="
    bg-white rounded-2xl
    p-8 border border-gray-200
    hover:border-gray-300
    transition-colors duration-200
  "
>
  {/* Header */}
  <div className="flex items-center gap-3 mb-6">
    <div className="
      w-12 h-12 rounded-xl
      bg-primary
      flex items-center justify-center
    ">
      <TrendingUp className="w-6 h-6 text-white" />
    </div>
    <div>
      <p className="text-xs font-bold uppercase tracking-wider text-gray-500">
        Total Value Locked
      </p>
      <p className="text-sm font-medium text-gray-900">On Mantle</p>
    </div>
  </div>
  
  {/* Main Value */}
  <div className="mb-4">
    <p className="text-5xl font-bold font-mono tracking-tight text-gray-900">
      $1,245,000
    </p>
    <p className="text-lg font-semibold text-gray-500 mt-1">USDT</p>
  </div>
  
  {/* Change Indicator */}
  <div className="flex items-center gap-2">
    <div className="
      flex items-center gap-1 px-3 py-1.5 rounded-lg
      bg-success/10 text-success font-bold text-sm
    ">
      <ArrowUp className="w-4 h-4" />
      <span>+24.5%</span>
    </div>
    <p className="text-sm text-gray-500 font-medium">vs last month</p>
  </div>
</div>
```ith gas report
forge test --gas-report
# Specific test
forge test --match-test testDeposit
```

---

## 👥 User Flows

### Lender Journey

#### 1. Connect Wallet
```
Landing Page → Click "Connect Wallet" (Top-right)
    ↓
RainbowKit Modal opens
    ↓
Select wallet provider (MetaMask, WalletConnect)
    ↓
Approve connection in wallet
    ↓
Success: Shows address + balance
```

#### 2. Deposit to Pool
```
Dashboard → Click "Lend" in sidebar
    ↓
View current pool stats (TVL, APY, your deposits)
    ↓
Click "Deposit USDT" button
    ↓
Modal opens with deposit form:
  - Enter amount (USDT)
  - Shows: Current balance, estimated APY
#### Loan Card - Professional Clean Design
```typescript
<div
  className="
    bg-white rounded-2xl
    p-8 border border-gray-200
    hover:border-gray-300
    transition-colors duration-200
  "
>
  {/* Header Section */}
  <div className="flex justify-between items-start mb-8">
    <div>
      {/* Loan Type Badge */}
      <div className="
        inline-flex items-center gap-2 mb-4
        px-4 py-2 rounded-lg
        bg-primary/10
        border border-primary/20
      ">
        <span className="text-sm font-bold text-primary uppercase tracking-wide">
          Personal Loan
        </span>
      </div>
      
      {/* Amount */}
      <h3 className="text-4xl font-bold font-mono tracking-tight text-gray-900">
        $5,000
      </h3>
      <p className="text-sm font-medium text-gray-500 mt-1">Principal Amount</p>
    </div>
    
    {/* Due Date */}
    <div className="text-right">
      <p className="text-xs font-semibold uppercase tracking-wide text-gray-500 mb-1">
        Due in
      </p>
      <div className="px-4 py-2 rounded-lg bg-gray-100">
        <p className="text-2xl font-bold text-gray-900">45</p>
        <p className="text-xs font-semibold text-gray-600">days</p>
      </div>
    </div>
  </div>
  
  {/* Progress Section */}
  <div className="mb-6">
    <div className="flex justify-between items-end mb-3">
      <p className="text-sm font-semibold text-gray-600 uppercase tracking-wide">
        Repayment Progress
      </p>
      <p className="text-2xl font-bold text-gray-900 font-mono">60%</p>
    </div>
    
    {/* Progress Bar */}
    <div className="relative h-3 bg-gray-200 rounded-full overflow-hidden">
      <div 
        className="absolute inset-y-0 left-0 bg-primary rounded-full"
        style={{ width: "60%" }}
      />
    </div>
    
    {/* Amount breakdown */}
    <div className="flex justify-between mt-3 text-sm">
      <span className="font-medium text-gray-600">
        Paid: <span className="text-gray-900 font-bold">$3,000</span>
      </span>
      <span className="font-medium text-gray-600">
        Remaining: <span className="text-gray-900 font-bold">$2,000</span>
      </span>
    </div>
  </div>
  
  {/* Collateral Health */}
  <div className="
    mb-6 p-5 rounded-xl
    bg-success/10 border border-success/20
  ">
    <div className="flex items-center justify-between">
      <div className="flex items-center gap-3">
        <div className="w-12 h-12 rounded-lg bg-success/20 flex items-center justify-center">
          <ShieldCheckIcon className="w-6 h-6 text-success" />
        </div>
        <div>
          <p className="text-xs font-semibold uppercase tracking-wide text-gray-600">
            Collateral Health
          </p>
          <p className="text-2xl font-bold text-success font-mono">155%</p>
        </div>
      </div>
      <div className="px-4 py-2 rounded-lg bg-success/20 text-success font-bold text-sm">
        Healthy
      </div>
    </div>
  </div>
  
  {/* Action Button */}
  <button
    className="
      w-full bg-primary hover:bg-primary-dark
      text-white font-bold text-lg
      py-4 rounded-xl
      transition-colors duration-200
      flex items-center justify-center gap-2
    "
  >
    <Wallet className="w-5 h-5" />
    Make Repayment
  </button>
</div>
```

// Additional icon imports for loan card
import { Wallet, Shield } from 'lucide-react';

// Shield icon used in collateral health section
<Shield className="w-6 h-6 text-success" />er withdrawal amount
    ↓
Click "Withdraw" → Wallet prompts transaction
    ↓
Success: Funds transferred to wallet + UI updates
```

---

### Borrower Journey

#### 1. Connect Wallet
```
(Same as lender flow)
```

#### 2. Check Credit Score
```
Dashboard → View "Credit Score" widget
    ↓
Shows:
  - Current score: 650/1000
  - Tier: Silver
  - Collateral requirement: 150%
  - Borrow limit: $5,000 USDT
    ↓
Click "View Details" → Navigate to Profile/Credit
    ↓
Detailed view:
  - Score history chart
  - Past loans and repayment record
  - Tier benefits (Gold = 120% collateral)
```

#### 3. Request Loan
```
Dashboard → Click "Borrow" in sidebar
    ↓
View available pool liquidity: $50,000 USDT
    ↓
Fill loan request form:
  - Step 1: Loan Details
    • Select loan type: Personal / Home / Business / Auto
    • Enter amount: $1,000 USDT
    • Select duration: 90 days
    • Shows interest rate: 8% APY for Personal
    
  - Step 2: Collateral
    • Choose collateral type: ETH or USDT
    • Shows required: $1,500 (150% ratio)
    • Enter collateral amount
    • Real-time validation: "0.5 ETH ≈ $1,520"
    
  - Step 3: Review
    • Loan amount: $1,000 USDT
    • Interest: $19.73 USDT (over 90 days)
    • Total repayment: $1,019.73 USDT
    • Collateral: 0.5 ETH
    • Liquidation price: $2,040 (if ETH drops below)
    ↓
Click "Request Loan"
    ↓
(If ETH collateral) Wallet prompts for ETH transfer → Confirm
    ↓
(If USDT collateral) Wallet prompts USDT approval → Confirm
    ↓
Wallet prompts loan creation transaction → Confirm
    ↓
Pending: Shows "Creating loan..." with progress bar
    ↓
Success: Toast "Loan approved! 1,000 USDT sent to your wallet"
    ↓
Redirect to "My Loans" page
```

#### 4. Manage Active Loans
```
My Loans Page → View all active loans (list/cards)
    ↓
Each loan card shows:
  - Loan ID: #12345
  - Amount: $1,000 USDT
  - Due: $1,019.73 USDT (in 60 days)
  - Progress bar: 33% repaid
  - Collateral health: 155% (Healthy 🟢)
  - Next payment: $339.91 (30 days)
    ↓
Click "Repay" on a loan card
    ↓
Repayment modal opens:
  - Total due: $1,019.73
  - Already paid: $0
  - Remaining: $1,019.73
  - Enter repayment amount (partial or full)
  - Shows: "After payment, remaining: $679.82"
    ↓
Click "Repay Now"
    ↓
Wallet prompts USDT approval (if needed) → Confirm
    ↓
Wallet prompts repayment transaction → Confirm
    ↓
Success: Collateral unlocked (if full repayment)
    ↓
Credit score updated: +100 points
    ↓
Borrow limit increased: $5,000 → $7,500
```

#### 5. Monitor Liquidation Risk
```
My Loans Page → Loan card shows warning
    ↓
Collateral health: 125% <AlertTriangle /> (Yellow warning)
    ↓
Banner: "Add collateral or repay to avoid liquidation at 120%"
    ↓
Click "Add Collateral" button
    ↓
Modal: Enter additional collateral amount
    ↓
Submit → Wallet confirms → Health restored to 150% <CheckCircle />
```

---

### Faucet Journey (Testnet Only)

#### 1. Access Faucet
```
Dashboard → Click "<Droplets /> Faucet" in sidebar
    ↓
Faucet page loads showing:
  - Current USDT balance
  - Last claim time
  - Next available claim countdown
  - Total claims made
```

#### 2. Claim Test USDT
```
Faucet Page → View claim status
    ↓
If eligible (24 hours passed):
  - Green "Claim 1,000 USDT" button enabled
  - Shows: "Ready to claim!"
    ↓
If not eligible:
  - Gray "Claim 1,000 USDT" button disabled
  - Shows: "Next claim available in 18h 45m 30s"
  - Live countdown timer updates every second
    ↓
Click "Claim 1,000 USDT" button
    ↓
Wallet prompts transaction signature → Confirm
    ↓
Pending: Shows "Processing claim..." with spinner
    ↓
Success: 
  - Toast notification: "<CheckCircle /> 1,000 USDT claimed successfully!"
  - Balance updates immediately
  - Timer resets to 24 hours
  - Claim history updates
    ↓
Redirect option: "Start Lending" or "Borrow Now" buttons
```

#### 3. View Claim History
```
Faucet Page → Scroll to "Claim History" section
    ↓
Displays table:
  - Date & Time of each claim
  - Amount claimed (1,000 USDT)
  - Transaction hash (link to explorer)
  - Total claims: e.g., "5 claims (5,000 USDT total)"
```

#### 4. First-Time User Flow
```
New user connects wallet → Dashboard loads
    ↓
Banner appears with <Gift /> icon: "Get started with 1,000 free USDT for testing!"
    ↓
Click "Claim Free USDT" → Navigate to Faucet
    ↓
Claim tokens → Success
    ↓
Onboarding tooltip: "Now you can deposit to earn APY or borrow against collateral"
    ↓
Suggested actions:
  - <Coins /> "Deposit 500 USDT to start earning" button
  - <BookOpen /> "Learn how borrowing works" button
```

---

## 🎨 Design Guidelines

### Color Usage Matrix

| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| **Primary CTAs** | Primary Purple | `#8B5CF6` | Deposit, Borrow, Connect Wallet |
| **Hover State** | Purple Light | `#A78BFA` | Button hover backgrounds |
| **Active/Pressed** | Purple Dark | `#7C3AED` | Button active state |
| **Secondary Actions** | White + Purple Border | `#FFF` + `#8B5CF6` | Cancel, View Details |
| **Success** | Green | `#10B981` | Successful tx, positive metrics |
| **Warning** | Yellow | `#FBBF24` | Low collateral, pending actions |
| **Error** | Red | `#EF4444` | Failed tx, liquidation alerts |
| **Backgrounds** | White | `#FFFFFF` | Main pages |
| **Cards** | Gray 50 | `#F9FAFB` | Card backgrounds |
| **Borders** | Gray 200 | `#E5E7EB` | Card borders, dividers |
| **Body Text** | Gray 600 | `#4B5563` | Paragraphs, descriptions |
| **Headings** | Gray 900 | `#111827` | Titles, important text |
| **Disabled** | Gray 400 | `#9CA3AF` | Disabled buttons, placeholders |

### Typography Scale Application

```typescript
// Hero Section
<h1 className="text-7xl font-bold text-gray-900">
  Decentralized Lending <span className="text-primary">Simplified</span>
</h1>

// Page Titles
<h2 className="text-5xl font-bold text-gray-900">Your Loans</h2>

// Section Headers
<h3 className="text-4xl font-semibold text-gray-900">Active Positions</h3>

// Card Titles
<h4 className="text-2xl font-semibold text-gray-900">Pool Statistics</h4>

// Stat Labels
<p className="text-sm font-medium text-gray-600 uppercase tracking-wide">
  Total Deposited
</p>

// Stat Values
<p className="text-3xl font-bold text-gray-900">$125,430</p>

// Body Text
<p className="text-lg text-gray-600 leading-relaxed">
  Earn competitive APY by lending USDT to borrowers...
</p>
```

### Spacing Application

```typescript
// Page Container
<div className="container mx-auto px-4 py-16">

// Section Spacing
<section className="mb-16">

// Card Grid
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

// Card Internal
<div className="p-6 space-y-4">

// Button Padding
<button className="px-6 py-3">

// Form Spacing
<form className="space-y-6">
  <div className="space-y-2">
    <label className="block text-sm font-medium">
    <input className="mt-1 w-full">
  </div>
</form>
```

### Component Design Patterns

#### Stat Card
```typescript
<div className="bg-white rounded-2xl p-6 border border-gray-200 shadow-sm">
  <div className="flex items-center justify-between mb-4">
    <h4 className="text-sm font-medium text-gray-600 uppercase">TVL</h4>
    <TrendUpIcon className="text-success" />
  </div>
  <p className="text-4xl font-bold text-gray-900 mb-2">$1.2M</p>
  <p className="text-sm text-gray-500">+12.3% from last month</p>
</div>
```

#### Loan Card
```typescript
<motion.div
  whileHover={{ scale: 1.02 }}
  className="bg-gray-50 rounded-2xl p-6 border border-gray-200"
>
  <div className="flex justify-between items-start mb-4">
    <div>
      <span className="text-xs bg-primary/10 text-primary px-2 py-1 rounded">
        Personal Loan
      </span>
      <h3 className="text-2xl font-bold text-gray-900 mt-2">$5,000</h3>
    </div>
    <div className="text-right">
      <p className="text-sm text-gray-600">Due in</p>
      <p className="text-lg font-semibold text-gray-900">45 days</p>
    </div>
  </div>
  
  {/* Progress Bar */}
  <div className="mb-4">
    <div className="flex justify-between text-sm mb-1">
      <span className="text-gray-600">Repayment Progress</span>
      <span className="font-medium text-gray-900">60%</span>
    </div>
    <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
      <div className="h-full bg-primary w-[60%]"></div>
    </div>
  </div>
  
  {/* Collateral Health */}
  <div className="flex items-center justify-between p-3 bg-white rounded-lg">
    <span className="text-sm text-gray-600">Collateral Health</span>
    <span className="flex items-center text-success font-medium">
      <CheckCircleIcon className="w-4 h-4 mr-1" />
      155% Healthy
    </span>
  </div>
  
  <button className="w-full mt-4 bg-primary hover:bg-primary-dark text-white font-semibold py-3 rounded-xl transition-colors">
    Make Repayment
  </button>
</motion.div>
```

#### Transaction Row
```typescript
import { ArrowDownCircle, ExternalLink } from 'lucide-react';

<div className="flex items-center justify-between p-4 hover:bg-gray-50 rounded-lg transition-colors">
  <div className="flex items-center space-x-4">
    <div className="w-10 h-10 bg-success/10 rounded-full flex items-center justify-center">
      <ArrowDownCircle className="w-5 h-5 text-success" />
    </div>
    <div>
      <p className="font-medium text-gray-900">Deposit</p>
      <p className="text-sm text-gray-500">2 hours ago</p>
    </div>
  </div>
  <div className="text-right">
    <p className="font-semibold text-gray-900">+1,000 USDT</p>
    <a href="#" className="text-xs text-primary hover:underline inline-flex items-center gap-1">
      View on Explorer
      <ExternalLink className="w-3 h-3" />
    </a>
  </div>
</div>
```

### Icon Usage Guide

#### Common Icons Throughout Application

```typescript
// Import icons from lucide-react
import {
  // Navigation
  LayoutDashboard,
  Coins,
  HandCoins,
  FileText,
  Waves,
  Droplets,
  Receipt,
  User,
  
  // Actions
  Wallet,
  Plus,
  Minus,
  Check,
  X,
  Edit,
  Trash2,
  Download,
  Upload,
  RefreshCw,
  
  // Status
  TrendingUp,
  TrendingDown,
  AlertCircle,
  CheckCircle,
  XCircle,
  Info,
  AlertTriangle,
  Shield,
  ShieldCheck,
  
  // UI
  ChevronDown,
  ChevronUp,
  ChevronLeft,
  ChevronRight,
  ArrowUp,
  ArrowDown,
  ArrowRight,
  ArrowLeft,
  ExternalLink,
  Copy,
  Search,
  Filter,
  Settings,
  Menu,
  
  // Finance
  DollarSign,
  CreditCard,
  Banknote,
  PiggyBank,
  TrendingUp as ChartUp,
  LineChart,
  BarChart3,
  
  // Time
  Clock,
  Calendar,
  Timer,
  History,
  
  // Special
  Gift,
  BookOpen,
  Zap
} from 'lucide-react';

// Usage example
<TrendingUp 
  className="w-6 h-6 text-success" 
  strokeWidth={2}
  aria-hidden="true" 
/>
```

#### Icon Size Standards
```typescript
// Extra Small (12px) - Inline text icons
className="w-3 h-3"

// Small (16px) - Secondary actions, labels
className="w-4 h-4"

// Medium (20px) - Primary buttons, cards
className="w-5 h-5"

// Large (24px) - Headers, feature icons
className="w-6 h-6"

// Extra Large (32px) - Hero sections, empty states
className="w-8 h-8"

// Huge (48px+) - Large feature cards
className="w-12 h-12"
```

#### Icon Color Patterns
```typescript
// Primary actions
<Wallet className="text-primary" />

// Success states
<CheckCircle className="text-success" />

// Warning states
<AlertTriangle className="text-warning" />

// Error states
<XCircle className="text-error" />

// Neutral/Inactive
<Info className="text-gray-400" />

// White on colored backgrounds
<TrendingUp className="text-white" />
```

#### Accessibility with Icons
```typescript
// Decorative icon (hide from screen readers)
<ArrowRight className="w-5 h-5" aria-hidden="true" />

// Icon button (provide label)
<button aria-label="Close modal">
  <X className="w-5 h-5" />
</button>

// Icon with text (icon is decorative)
<div className="flex items-center gap-2">
  <CheckCircle className="w-5 h-5 text-success" aria-hidden="true" />
  <span>Payment successful</span>
</div>
```

### Animation Guidelines

#### Page Transitions
```typescript
// Use in layout.tsx
<motion.div
  initial="initial"
  animate="animate"
  exit="exit"
  variants={pageVariants}
>
  {children}
</motion.div>
```

#### Stagger Children
```typescript
// Use for lists
<motion.div
  variants={containerVariants}
  initial="hidden"
  animate="visible"
>
  {items.map(item => (
    <motion.div key={item.id} variants={itemVariants}>
      {/* Content */}
    </motion.div>
  ))}
</motion.div>

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.1 }
  }
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 }
};
```

#### Loading States
```typescript
// Skeleton loader
<div className="animate-pulse space-y-4">
  <div className="h-8 bg-gray-200 rounded w-3/4"></div>
  <div className="h-4 bg-gray-200 rounded w-full"></div>
  <div className="h-4 bg-gray-200 rounded w-5/6"></div>
</div>
```

---

## 🛠 Development Workflow

### Commands Reference

#### Frontend Development
```bash
# Development
pnpm dev              # Start dev server (localhost:3000)
pnpm build            # Build for production
pnpm start            # Serve production build
pnpm lint             # Run ESLint
pnpm format           # Format with Prettier
pnpm type-check       # TypeScript validation

# Testing (if added)
pnpm test             # Run Vitest tests
pnpm test:watch       # Watch mode
```

#### Smart Contract Development
```bash
# Building
forge build           # Compile contracts
forge clean           # Clean build artifacts

# Testing
forge test            # Run all tests
forge test -vvv       # Verbose output
forge test --match-test testDeposit  # Run specific test
forge test --gas-report  # Gas usage report
forge coverage        # Coverage report

# Deployment
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast
forge create src/LendingPool.sol:LendingPool --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Interaction
cast call $CONTRACT "totalLiquidity()" --rpc-url $RPC_URL
cast send $CONTRACT "deposit(uint256)" 1000000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Verification
forge verify-contract $ADDRESS src/LendingPool.sol:LendingPool --etherscan-api-key $API_KEY
```

### Git Workflow

```bash
# Feature development
git checkout -b feature/loan-repayment-ui
# Make changes...
git add .
git commit -m "feat: add loan repayment modal with validation"
git push origin feature/loan-repayment-ui
# Create PR on GitHub

# Commit message convention:
# feat: New feature
# fix: Bug fix
# docs: Documentation update
# style: Code style (formatting, no logic change)
# refactor: Code refactoring
# test: Test updates
# chore: Build/config changes
```

### Testing Strategy

#### Smart Contracts
```solidity
// Unit test example
function testDeposit() public {
    uint256 depositAmount = 1000e6; // 1000 USDT
    
    // Arrange
    usdt.mint(lender, depositAmount);
    vm.startPrank(lender);
    usdt.approve(address(pool), depositAmount);
    
    // Act
    pool.deposit(depositAmount);
    
    // Assert
    assertEq(pool.balanceOf(lender), depositAmount);
    assertEq(pool.totalLiquidity(), depositAmount);
    vm.stopPrank();
}

// Integration test
function testFullLoanCycle() public {
    // 1. Lender deposits
    // 2. Borrower requests loan
    // 3. Borrower repays
    // 4. Lender withdraws
}

// Invariant test
function invariant_totalLiquidityMatchesBalance() public {
    assertEq(
        pool.totalLiquidity(),
        usdt.balanceOf(address(pool))
    );
}
```

#### Frontend (Optional with Vitest)
```typescript
// Component test
describe('LoanCard', () => {
  it('displays loan details correctly', () => {
    render(<LoanCard loan={mockLoan} />);
    expect(screen.getByText('$5,000')).toBeInTheDocument();
    expect(screen.getByText('Personal Loan')).toBeInTheDocument();
  });
  
  it('shows warning when collateral is low', () => {
    const lowCollateralLoan = { ...mockLoan, collateralHealth: 125 };
    render(<LoanCard loan={lowCollateralLoan} />);
    expect(screen.getByText(/add collateral/i)).toBeInTheDocument();
  });
});
```

---

## ✅ Code Quality Standards

### TypeScript Configuration
```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

### Naming Conventions
```typescript
// ✅ Good
const userBalance = useUserBalance();
function calculateInterest(principal: bigint): bigint {}
interface LoanDetails {}
type TransactionStatus = 'pending' | 'success' | 'failed';

// ❌ Bad
const x = useUserBalance();
function calc(p: bigint): bigint {}
interface loan {}
type status = string;
```

### Error Handling
```typescript
// Contract interactions
try {
  const hash = await writeContract({
    address: CONTRACT_ADDRESS,
    abi: LendingPoolABI,
    functionName: 'deposit',
    args: [amount]
  });
  
  toast.success('Deposit initiated!', {
    action: {
      label: 'View Transaction',
      onClick: () => window.open(`${EXPLORER_URL}/tx/${hash}`)
    }
  });
  
} catch (error) {
  if (error instanceof Error) {
    // User rejected
    if (error.message.includes('User rejected')) {
      toast.error('Transaction cancelled');
      return;
    }
    
    // Insufficient balance
    if (error.message.includes('insufficient')) {
      toast.error('Insufficient balance for deposit');
      return;
    }
    
    // Generic error
    toast.error('Deposit failed. Please try again.');
    console.error('Deposit error:', error);
  }
}
```

### Accessibility Requirements
```typescript
// Buttons
<button
  className="..."
  aria-label="Deposit USDT to lending pool"
  disabled={isLoading}
>
  {isLoading ? <Spinner aria-hidden="true" /> : 'Deposit'}
</button>

// Form inputs
<label htmlFor="amount" className="block text-sm font-medium">
  Deposit Amount
</label>
<input
  id="amount"
  type="number"
  aria-describedby="amount-hint"
  aria-invalid={!!error}
/>
{error && <p id="amount-error" role="alert">{error}</p>}

// Navigation
<nav aria-label="Main navigation">
  <ul role="list">
    <li><a href="/dashboard" aria-current={isActive}>Dashboard</a></li>
  </ul>
</nav>
```

### Performance Optimization
```typescript
// Memoize expensive calculations
const dueAmount = useMemo(() => 
  calculateDueAmount(loan.principal, loan.interestRate, loan.duration),
  [loan.principal, loan.interestRate, loan.duration]
);

// Debounce user input
const debouncedAmount = useDebounce(inputAmount, 500);

// Virtual scrolling for long lists
<VirtualList
  items={transactions}
  height={600}
  itemHeight={80}
  renderItem={(tx) => <TransactionRow transaction={tx} />}
/>

// Image optimization
<Image
  src="/hero-bg.jpg"
  alt="Hero background"
  width={1920}
  height={1080}
  priority
  placeholder="blur"
/>
```

### File Organization Rules
1. **Max 500 lines per file** - Split into smaller modules if exceeded
2. **One component per file** - Except for tightly coupled components
3. **Group imports** - External → Internal → Types → Styles
4. **Export at bottom** - Default export last

```typescript
// ✅ Good structure
import React from 'react';
import { motion } from 'framer-motion';

import { Button } from '@/components/ui';
import { useLoans } from '@/hooks';

import type { Loan } from '@/types';

import styles from './LoanCard.module.css';

export function LoanCard({ loan }: { loan: Loan }) {
  // Component logic (max 300 lines)
}
```

---

## 🔧 Troubleshooting

### Common Issues & Solutions

#### Issue: Wallet Connection Fails
```
Error: "Chain not supported" or connection hangs
```
**Solutions:**
1. Verify Mantle testnet is added to wallet:
   ```javascript
   // Add to wagmi config
   const mantleTestnet = {
     id: 5003,
     name: 'Mantle Sepolia',
     network: 'mantle-sepolia',
     nativeCurrency: { name: 'MNT', symbol: 'MNT', decimals: 18 },
     rpcUrls: {
       default: { http: ['https://rpc.sepolia.mantle.xyz'] },
       public: { http: ['https://rpc.sepolia.mantle.xyz'] }
     },
     blockExplorers: {
       default: { name: 'Explorer', url: 'https://explorer.sepolia.mantle.xyz' }
     }
   };
   ```
2. Clear browser cache and wallet cache
3. Try different wallet (MetaMask vs WalletConnect)

#### Issue: Transaction Fails with "Insufficient Funds"
```
Error: Transaction reverted
```
**Solutions:**
1. Check token balance: `cast call $USDT "balanceOf(address)" $USER_ADDRESS`
2. Verify approval: User must approve USDT spending first
3. Ensure enough MNT for gas fees
4. Check contract allowance: `cast call $USDT "allowance(address,address)" $USER $CONTRACT`

#### Issue: Contract Read Returns Stale Data
```
Problem: UI shows old balance after transaction
```
**Solutions:**
1. Use `watch: true` in Wagmi hooks:
   ```typescript
   const { data } = useReadContract({
     address: CONTRACT,
     abi: ABI,
     functionName: 'balanceOf',
     args: [address],
     watch: true // Polls for updates
   });
   ```
2. Manually refetch after transaction:
   ```typescript
   await waitForTransaction({ hash });
   refetch(); // Trigger manual refetch
   ```

#### Issue: Chainlink Price Feed Returns 0
```
Error: Price feed not set or stale
```
**Solutions:**
1. Verify price feed address is correct for network
2. Check oracle has recent data (less than 15 min old)
3. Use testnet mock oracle if Chainlink unavailable:
   ```solidity
   contract MockPriceFeed {
       function latestRoundData() external pure returns (
           uint80, int256, uint256, uint256, uint80
       ) {
           return (0, 3000e8, block.timestamp, block.timestamp, 0);
       }
   }
   ```

#### Issue: Build Fails with "Module not found"
```
Error: Cannot find module '@/components/ui/Button'
```
**Solutions:**
1. Check tsconfig.json paths:
   ```json
   {
     "compilerOptions": {
       "baseUrl": ".",
       "paths": {
         "@/*": ["./src/*"]
       }
     }
   }
   ```
2. Verify file exists at correct path
3. Restart dev server after config changes

#### Issue: Gas Estimation Failed
```
Error: Cannot estimate gas
```
**Solutions:**
1. Simulation likely failed - check contract reverts
2. Verify contract state allows transaction (e.g., not paused)
3. Check collateral/balance requirements are met
4. Test with lower amount to isolate issue

---

## 🤝 Contributing

### Getting Started
1. **Fork the repository** on GitHub
2. **Clone your fork**: `git clone https://github.com/YOUR_USERNAME/onloan-mantle.git`
3. **Create a branch**: `git checkout -b feature/your-feature-name`
4. **Make changes** following code standards above
5. **Test thoroughly** (contract tests + manual frontend testing)
6. **Commit with conventional commits**: `git commit -m "feat: add loan calculator"`
7. **Push to your fork**: `git push origin feature/your-feature-name`
8. **Create Pull Request** on main repository

### Code Review Checklist
Before submitting PR:
- [ ] All contract tests pass (`forge test`)
- [ ] No TypeScript errors (`pnpm type-check`)
- [ ] Code follows style guide (max line lengths, naming)
- [ ] New features include tests
- [ ] Documentation updated if needed
- [ ] No console.logs or debug code
- [ ] Accessibility checked (keyboard navigation, ARIA labels)
- [ ] Responsive design tested (mobile, tablet, desktop)

### Branch Naming
- `feature/loan-calculator` - New features
- `fix/repayment-bug` - Bug fixes
- `docs/update-readme` - Documentation
- `refactor/loan-manager` - Code refactoring
- `test/add-liquidation-tests` - Test additions

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Testing
- [ ] Contract tests added/updated
- [ ] Frontend manually tested
- [ ] Responsive design verified
- [ ] Accessibility checked

## Screenshots (if UI change)
[Add screenshots]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

---

## 📚 Additional Resources

### Documentation Links
- **Mantle Network**: [docs.mantle.xyz](https://docs.mantle.xyz)
- **Wagmi**: [wagmi.sh](https://wagmi.sh)
- **Viem**: [viem.sh](https://viem.sh)
- **Foundry Book**: [book.getfoundry.sh](https://book.getfoundry.sh)
- **Next.js 14**: [nextjs.org/docs](https://nextjs.org/docs)
- **Tailwind CSS**: [tailwindcss.com](https://tailwindcss.com)
- **Framer Motion**: [framer.com/motion](https://www.framer.com/motion)

### Community & Support
- **GitHub Issues**: Report bugs and request features
- **Discord**: Join community discussions (link TBD)
- **Twitter**: [@OnLoanProtocol](https://twitter.com/OnLoanProtocol) for updates

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

Built with love for the Mantle ecosystem. Special thanks to:
- Mantle Network team for L2 infrastructure
- OpenZeppelin for secure contract libraries
- Chainlink for reliable price oracles
- Foundry team for excellent dev tools

---

**Ready to build trustless lending?** Start with `pnpm install` and let's revolutionize DeFi together.
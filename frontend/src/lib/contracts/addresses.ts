import type { Address } from 'viem';

export interface ContractAddresses {
  mockUSDT: Address;
  usdtFaucet: Address;
  interestCalculator: Address;
  collateralManager: Address;
  creditScore: Address;
  lendingPool: Address;
  loanManager: Address;
}

const MANTLE_SEPOLIA_ADDRESSES: ContractAddresses = {
  mockUSDT: (import.meta.env.VITE_MOCK_USDT_ADDRESS || '0x0000000000000000000000000000000000000000') as Address,
  usdtFaucet: (import.meta.env.VITE_USDT_FAUCET_ADDRESS || '0x0000000000000000000000000000000000000000') as Address,
  interestCalculator: (import.meta.env.VITE_INTEREST_CALCULATOR_ADDRESS || '0x0000000000000000000000000000000000000000') as Address,
  collateralManager: (import.meta.env.VITE_COLLATERAL_MANAGER_ADDRESS || '0x0000000000000000000000000000000000000000') as Address,
  creditScore: (import.meta.env.VITE_CREDIT_SCORE_ADDRESS || '0x0000000000000000000000000000000000000000') as Address,
  lendingPool: (import.meta.env.VITE_LENDING_POOL_ADDRESS || '0x0000000000000000000000000000000000000000') as Address,
  loanManager: (import.meta.env.VITE_LOAN_MANAGER_ADDRESS || '0x0000000000000000000000000000000000000000') as Address,
};

const LOCAL_ADDRESSES: ContractAddresses = {
  mockUSDT: '0x5FbDB2315678afecb367f032d93F642f64180aa3' as Address,
  usdtFaucet: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512' as Address,
  interestCalculator: '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9' as Address,
  collateralManager: '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707' as Address,
  creditScore: '0x0165878A594ca255338adfa4d48449f69242Eb8F' as Address,
  lendingPool: '0xa513E6E4b8f2a923D98304ec87F64353C4D5C853' as Address,
  loanManager: '0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6' as Address,
};

const isLocalDevelopment = import.meta.env.VITE_USE_LOCAL_CONTRACTS === 'true';

export const contractAddresses: ContractAddresses = isLocalDevelopment 
  ? LOCAL_ADDRESSES 
  : MANTLE_SEPOLIA_ADDRESSES;

export const getContractAddress = (contractName: keyof ContractAddresses): Address => {
  return contractAddresses[contractName];
};

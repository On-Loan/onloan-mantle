import { useMemo } from 'react';
import type { Address } from 'viem';
import { contractAddresses } from '../lib/contracts/addresses';
import {
  MockUSDTABI,
  USDTFaucetABI,
  InterestCalculatorABI,
  CollateralManagerABI,
  CreditScoreABI,
  LendingPoolABI,
  LoanManagerABI,
} from '../lib/contracts/abis';

export type ContractName =
  | 'mockUSDT'
  | 'usdtFaucet'
  | 'interestCalculator'
  | 'collateralManager'
  | 'creditScore'
  | 'lendingPool'
  | 'loanManager';

interface ContractConfig {
  address: Address;
  abi: readonly unknown[];
}

const contractABIs = {
  mockUSDT: MockUSDTABI,
  usdtFaucet: USDTFaucetABI,
  interestCalculator: InterestCalculatorABI,
  collateralManager: CollateralManagerABI,
  creditScore: CreditScoreABI,
  lendingPool: LendingPoolABI,
  loanManager: LoanManagerABI,
} as const;

export function useContract(contractName: ContractName): ContractConfig {
  return useMemo(
    () => ({
      address: contractAddresses[contractName],
      abi: contractABIs[contractName],
    }),
    [contractName]
  );
}

export function useContracts() {
  return useMemo(
    () => ({
      mockUSDT: {
        address: contractAddresses.mockUSDT,
        abi: MockUSDTABI,
      },
      usdtFaucet: {
        address: contractAddresses.usdtFaucet,
        abi: USDTFaucetABI,
      },
      interestCalculator: {
        address: contractAddresses.interestCalculator,
        abi: InterestCalculatorABI,
      },
      collateralManager: {
        address: contractAddresses.collateralManager,
        abi: CollateralManagerABI,
      },
      creditScore: {
        address: contractAddresses.creditScore,
        abi: CreditScoreABI,
      },
      lendingPool: {
        address: contractAddresses.lendingPool,
        abi: LendingPoolABI,
      },
      loanManager: {
        address: contractAddresses.loanManager,
        abi: LoanManagerABI,
      },
    }),
    []
  );
}

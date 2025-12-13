import { useAccount, useReadContract } from 'wagmi';
import { useEffect, useState } from 'react';
import { formatUnits } from 'viem';
import { LendingPoolABI } from '../lib/contracts/abis/LendingPool';
import { LoanManagerABI } from '../lib/contracts/abis/LoanManager';
import { CreditScoreABI } from '../lib/contracts/abis/CreditScore';
import { contractAddresses } from '../lib/contracts/addresses';

export interface UserBalance {
  totalDeposited: string;
  availableToWithdraw: string;
  earnedInterest: string;
  activeLoans: number;
  totalBorrowed: string;
  creditScore: number;
  isLoading: boolean;
}

export const useUserBalance = (): UserBalance => {
  const { address, isConnected } = useAccount();
  const [userBalance, setUserBalance] = useState<UserBalance>({
    totalDeposited: '0',
    availableToWithdraw: '0',
    earnedInterest: '0',
    activeLoans: 0,
    totalBorrowed: '0',
    creditScore: 300,
    isLoading: true,
  });

  // Fetch user deposits
  const { data: deposits, isLoading: depositsLoading } = useReadContract({
    address: contractAddresses.lendingPool,
    abi: LendingPoolABI,
    functionName: 'getUserDeposit',
    args: address ? [address] : undefined,
    query: { enabled: isConnected && !!address },
  });

  // Fetch user interest earned
  const { data: interest, isLoading: interestLoading } = useReadContract({
    address: contractAddresses.lendingPool,
    abi: LendingPoolABI,
    functionName: 'calculateInterest',
    args: address ? [address] : undefined,
    query: { enabled: isConnected && !!address },
  });

  // Fetch active loans count
  const { data: loansData, isLoading: loansLoading } = useReadContract({
    address: contractAddresses.loanManager,
    abi: LoanManagerABI,
    functionName: 'getUserLoans',
    args: address ? [address] : undefined,
    query: { enabled: isConnected && !!address },
  });

  // Fetch credit score
  const { data: score, isLoading: scoreLoading } = useReadContract({
    address: contractAddresses.creditScore,
    abi: CreditScoreABI,
    functionName: 'getCreditScore',
    args: address ? [address] : undefined,
    query: { enabled: isConnected && !!address },
  });

  useEffect(() => {
    if (!isConnected) {
      setUserBalance({
        totalDeposited: '0',
        availableToWithdraw: '0',
        earnedInterest: '0',
        activeLoans: 0,
        totalBorrowed: '0',
        creditScore: 300,
        isLoading: false,
      });
      return;
    }

    const isLoading = depositsLoading || interestLoading || loansLoading || scoreLoading;

    if (!isLoading) {
      const depositAmount = deposits ? formatUnits(deposits as bigint, 6) : '0';
      const interestAmount = interest ? formatUnits(interest as bigint, 6) : '0';
      const userLoans = (loansData as bigint[]) || [];
      const activeLoansCount = userLoans.length;
      
      // Calculate total borrowed from active loans (placeholder calculation)
      const totalBorrowed = activeLoansCount > 0 ? (Number(depositAmount) * 0.8).toFixed(2) : '0';
      
      const creditScoreValue = score ? Number(score) : 300;

      setUserBalance({
        totalDeposited: depositAmount,
        availableToWithdraw: depositAmount,
        earnedInterest: interestAmount,
        activeLoans: activeLoansCount,
        totalBorrowed,
        creditScore: creditScoreValue,
        isLoading: false,
      });
    } else {
      setUserBalance((prev) => ({ ...prev, isLoading: true }));
    }
  }, [deposits, interest, loansData, score, depositsLoading, interestLoading, loansLoading, scoreLoading, isConnected]);

  return userBalance;
};

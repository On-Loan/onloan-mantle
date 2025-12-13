import { useAccount, useReadContract, useWriteContract, useWatchContractEvent } from 'wagmi';
import { useState, useEffect } from 'react';
import { formatUnits, parseUnits } from 'viem';
import { LendingPoolABI } from '../lib/contracts/abis/LendingPool';
import { MockUSDTABI } from '../lib/contracts/abis/MockUSDT';
import { contractAddresses } from '../lib/contracts/addresses';

export interface LendingPoolData {
  totalDeposited: string;
  availableToWithdraw: string;
  earnedInterest: string;
  currentAPY: string;
  poolShare: string;
  totalPoolLiquidity: string;
  utilizationRate: string;
  isLoading: boolean;
}

export const useLendingPool = () => {
  const { address, isConnected } = useAccount();
  const [poolData, setPoolData] = useState<LendingPoolData>({
    totalDeposited: '0',
    availableToWithdraw: '0',
    earnedInterest: '0',
    currentAPY: '8.5',
    poolShare: '0',
    totalPoolLiquidity: '0',
    utilizationRate: '0',
    isLoading: true,
  });

  // Get user deposit
  const { data: userDeposit, isLoading: depositLoading, refetch: refetchDeposit } = useReadContract({
    address: contractAddresses.lendingPool,
    abi: LendingPoolABI,
    functionName: 'getUserDeposit',
    args: address ? [address] : undefined,
    query: { enabled: isConnected && !!address },
  });

  // Get earned interest
  const { data: interest, isLoading: interestLoading, refetch: refetchInterest } = useReadContract({
    address: contractAddresses.lendingPool,
    abi: LendingPoolABI,
    functionName: 'calculateInterest',
    args: address ? [address] : undefined,
    query: { enabled: isConnected && !!address },
  });

  // Get total pool liquidity
  const { data: poolLiquidity, refetch: refetchLiquidity } = useReadContract({
    address: contractAddresses.lendingPool,
    abi: LendingPoolABI,
    functionName: 'totalLiquidity',
    query: { enabled: true },
  });

  // Get user USDT balance
  const { data: usdtBalance, refetch: refetchBalance } = useReadContract({
    address: contractAddresses.mockUSDT,
    abi: MockUSDTABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: { enabled: isConnected && !!address },
  });

  // Get USDT allowance
  const { data: allowance, refetch: refetchAllowance } = useReadContract({
    address: contractAddresses.mockUSDT,
    abi: MockUSDTABI,
    functionName: 'allowance',
    args: address ? [address, contractAddresses.lendingPool] : undefined,
    query: { enabled: isConnected && !!address },
  });

  // Write contracts
  const { 
    writeContract: writeDeposit, 
    isPending: isDepositPending,
    isSuccess: isDepositSuccess,
    isError: isDepositError,
  } = useWriteContract();

  const { 
    writeContract: writeWithdraw, 
    isPending: isWithdrawPending,
    isSuccess: isWithdrawSuccess,
    isError: isWithdrawError,
  } = useWriteContract();

  const { 
    writeContract: writeApprove, 
    isPending: isApprovePending,
    isSuccess: isApproveSuccess,
  } = useWriteContract();

  // Watch for deposit events
  useWatchContractEvent({
    address: contractAddresses.lendingPool,
    abi: LendingPoolABI,
    eventName: 'Deposit',
    onLogs: () => {
      refetchDeposit();
      refetchInterest();
      refetchLiquidity();
      refetchBalance();
    },
  });

  // Watch for withdraw events
  useWatchContractEvent({
    address: contractAddresses.lendingPool,
    abi: LendingPoolABI,
    eventName: 'Withdraw',
    onLogs: () => {
      refetchDeposit();
      refetchInterest();
      refetchLiquidity();
      refetchBalance();
    },
  });

  // Calculate pool data
  useEffect(() => {
    if (!isConnected) {
      setPoolData((prev) => ({ ...prev, isLoading: false }));
      return;
    }

    const deposit = userDeposit ? formatUnits(userDeposit as bigint, 6) : '0';
    const earned = interest ? formatUnits(interest as bigint, 6) : '0';
    const available = deposit; // Available to withdraw (excluding interest for now)
    const liquidity = poolLiquidity ? formatUnits(poolLiquidity as bigint, 6) : '0';
    
    // Calculate pool share
    const poolSharePercent = Number(liquidity) > 0 
      ? ((Number(deposit) / Number(liquidity)) * 100).toFixed(2)
      : '0';

    // Mock utilization rate (would come from contract in production)
    const utilization = '65.4';

    setPoolData({
      totalDeposited: deposit,
      availableToWithdraw: available,
      earnedInterest: earned,
      currentAPY: '8.5', // Mock APY - should come from InterestCalculator
      poolShare: poolSharePercent,
      totalPoolLiquidity: liquidity,
      utilizationRate: utilization,
      isLoading: depositLoading || interestLoading,
    });
  }, [userDeposit, interest, poolLiquidity, isConnected, depositLoading, interestLoading]);

  // Approve USDT
  const approve = async (amount: string) => {
    if (!address) return;

    const amountInUnits = parseUnits(amount, 6);
    
    writeApprove({
      address: contractAddresses.mockUSDT,
      abi: MockUSDTABI,
      functionName: 'approve',
      args: [contractAddresses.lendingPool, amountInUnits],
    });
  };

  // Deposit USDT
  const deposit = async (amount: string) => {
    if (!address) return;

    const amountInUnits = parseUnits(amount, 6);
    
    writeDeposit({
      address: contractAddresses.lendingPool,
      abi: LendingPoolABI,
      functionName: 'deposit',
      args: [amountInUnits],
    });
  };

  // Withdraw USDT
  const withdraw = async (amount: string) => {
    if (!address) return;

    const amountInUnits = parseUnits(amount, 6);
    
    writeWithdraw({
      address: contractAddresses.lendingPool,
      abi: LendingPoolABI,
      functionName: 'withdraw',
      args: [amountInUnits],
    });
  };

  return {
    ...poolData,
    usdtBalance: usdtBalance ? formatUnits(usdtBalance as bigint, 6) : '0',
    allowance: allowance ? formatUnits(allowance as bigint, 6) : '0',
    approve,
    deposit,
    withdraw,
    isDepositPending,
    isDepositSuccess,
    isDepositError,
    isWithdrawPending,
    isWithdrawSuccess,
    isWithdrawError,
    isApprovePending,
    isApproveSuccess,
    refetchAllowance,
  };
};

import { useAccount, useReadContract, useWriteContract, useWatchContractEvent } from 'wagmi';
import { useEffect, useState } from 'react';
import { formatUnits } from 'viem';
import { USDTFaucetABI } from '../lib/contracts/abis/USDTFaucet';
import { MockUSDTABI } from '../lib/contracts/abis/MockUSDT';
import { contractAddresses } from '../lib/contracts/addresses';

export interface FaucetData {
  canClaim: boolean;
  lastClaimTime: number;
  usdtBalance: string;
  timeUntilNextClaim: number;
  claimAmount: string;
  isLoading: boolean;
}

export const useFaucet = () => {
  const { address, isConnected } = useAccount();
  const [faucetData, setFaucetData] = useState<FaucetData>({
    canClaim: false,
    lastClaimTime: 0,
    usdtBalance: '0',
    timeUntilNextClaim: 0,
    claimAmount: '1000',
    isLoading: true,
  });

  // Get last claim time
  const { data: lastClaim, isLoading: lastClaimLoading, refetch: refetchLastClaim } = useReadContract({
    address: contractAddresses.usdtFaucet,
    abi: USDTFaucetABI,
    functionName: 'lastClaimTime',
    args: address ? [address] : undefined,
    query: { enabled: isConnected && !!address },
  });

  // Get USDT balance
  const { data: balance, isLoading: balanceLoading, refetch: refetchBalance } = useReadContract({
    address: contractAddresses.mockUSDT,
    abi: MockUSDTABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: { enabled: isConnected && !!address },
  });

  // Get claim amount
  const { data: claimAmountData } = useReadContract({
    address: contractAddresses.usdtFaucet,
    abi: USDTFaucetABI,
    functionName: 'CLAIM_AMOUNT',
  });

  // Write contract for claiming
  const { writeContract, isPending, isSuccess, isError, error } = useWriteContract();

  // Watch for claim events
  useWatchContractEvent({
    address: contractAddresses.usdtFaucet,
    abi: USDTFaucetABI,
    eventName: 'TokensClaimed',
    onLogs: () => {
      refetchLastClaim();
      refetchBalance();
    },
  });

  // Calculate time until next claim
  useEffect(() => {
    if (!isConnected || !lastClaim) {
      setFaucetData((prev) => ({ ...prev, isLoading: false }));
      return;
    }

    const updateTimer = () => {
      const now = Math.floor(Date.now() / 1000);
      const lastClaimTimestamp = Number(lastClaim);
      const cooldownPeriod = 24 * 60 * 60; // 24 hours in seconds
      const nextClaimTime = lastClaimTimestamp + cooldownPeriod;
      const timeRemaining = Math.max(0, nextClaimTime - now);
      const canClaimNow = timeRemaining === 0;

      const usdtBal = balance ? formatUnits(balance as bigint, 6) : '0';
      const claimAmt = claimAmountData ? formatUnits(claimAmountData as bigint, 6) : '1000';

      setFaucetData({
        canClaim: canClaimNow,
        lastClaimTime: lastClaimTimestamp,
        usdtBalance: usdtBal,
        timeUntilNextClaim: timeRemaining,
        claimAmount: claimAmt,
        isLoading: lastClaimLoading || balanceLoading,
      });
    };

    updateTimer();
    const interval = setInterval(updateTimer, 1000);

    return () => clearInterval(interval);
  }, [lastClaim, balance, claimAmountData, isConnected, lastClaimLoading, balanceLoading]);

  const claim = async () => {
    if (!address || !faucetData.canClaim) return;

    try {
      writeContract({
        address: contractAddresses.usdtFaucet,
        abi: USDTFaucetABI,
        functionName: 'claimTokens',
      });
    } catch (err) {
      console.error('Claim error:', err);
    }
  };

  return {
    ...faucetData,
    claim,
    isPending,
    isSuccess,
    isError,
    error,
  };
};

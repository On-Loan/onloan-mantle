import { useState } from 'react';
import { useAccount } from 'wagmi';
import { Wallet, Info } from 'lucide-react';
import { Card } from '../components/ui';
import { useLendingPool } from '../hooks/useLendingPool';
import { DepositForm } from '../features/lending/DepositForm';
import { WithdrawForm } from '../features/lending/WithdrawForm';
import { LenderStats } from '../features/lending/LenderStats';
import { EarningsChart } from '../features/lending/EarningsChart';

type Tab = 'deposit' | 'withdraw';

export const Lend = () => {
  const { isConnected } = useAccount();
  const [activeTab, setActiveTab] = useState<Tab>('deposit');
  const poolData = useLendingPool();

  // Wallet connection guard
  if (!isConnected) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Card variant="elevated" className="max-w-md w-full text-center">
          <div className="py-12 space-y-6">
            <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-primary-100 to-primary-200 dark:from-primary-900/40 dark:to-primary-800/40">
              <Wallet className="h-10 w-10 text-primary-600 dark:text-primary-400" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
                Connect Your Wallet
              </h2>
              <p className="text-gray-600 dark:text-gray-400">
                Connect your wallet to start lending and earning interest
              </p>
            </div>
          </div>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-gray-100 mb-2">
            Lend & Earn
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Deposit USDT to earn competitive interest rates
          </p>
        </div>
      </div>

      {/* Info Banner */}
      <Card variant="standard" className="border-blue-200 dark:border-blue-800 bg-blue-50 dark:bg-blue-900/20">
        <div className="flex items-start gap-3">
          <Info className="h-5 w-5 text-blue-600 dark:text-blue-400 flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm text-blue-900 dark:text-blue-100 font-medium mb-1">
              Earn Passive Income
            </p>
            <p className="text-sm text-blue-800 dark:text-blue-200">
              Your deposits provide liquidity for borrowers and earn interest continuously. 
              APY varies based on pool utilization. Withdraw anytime with no lock-up period.
            </p>
          </div>
        </div>
      </Card>

      {/* Stats */}
      <LenderStats
        totalDeposited={poolData.totalDeposited}
        earnedInterest={poolData.earnedInterest}
        currentAPY={poolData.currentAPY}
        poolShare={poolData.poolShare}
        isLoading={poolData.isLoading}
      />

      {/* Main Content */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column - Forms */}
        <div className="lg:col-span-2 space-y-6">
          {/* Tabs */}
          <div className="flex gap-2 p-1 bg-gray-100 dark:bg-gray-800 rounded-xl">
            <button
              onClick={() => setActiveTab('deposit')}
              className={`flex-1 py-2.5 px-4 rounded-lg font-medium text-sm transition-colors ${
                activeTab === 'deposit'
                  ? 'bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 shadow-sm'
                  : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100'
              }`}
            >
              Deposit
            </button>
            <button
              onClick={() => setActiveTab('withdraw')}
              className={`flex-1 py-2.5 px-4 rounded-lg font-medium text-sm transition-colors ${
                activeTab === 'withdraw'
                  ? 'bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 shadow-sm'
                  : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100'
              }`}
            >
              Withdraw
            </button>
          </div>

          {/* Tab Content */}
          {activeTab === 'deposit' ? (
            <DepositForm
              usdtBalance={poolData.usdtBalance}
              allowance={poolData.allowance}
              currentAPY={poolData.currentAPY}
              onApprove={poolData.approve}
              onDeposit={poolData.deposit}
              isApprovePending={poolData.isApprovePending}
              isApproveSuccess={poolData.isApproveSuccess}
              isDepositPending={poolData.isDepositPending}
              isDepositSuccess={poolData.isDepositSuccess}
              isDepositError={poolData.isDepositError}
              refetchAllowance={poolData.refetchAllowance}
            />
          ) : (
            <WithdrawForm
              totalDeposited={poolData.totalDeposited}
              availableToWithdraw={poolData.availableToWithdraw}
              earnedInterest={poolData.earnedInterest}
              totalPoolLiquidity={poolData.totalPoolLiquidity}
              onWithdraw={poolData.withdraw}
              isWithdrawPending={poolData.isWithdrawPending}
              isWithdrawSuccess={poolData.isWithdrawSuccess}
              isWithdrawError={poolData.isWithdrawError}
            />
          )}
        </div>

        {/* Right Column - Earnings Chart */}
        <div className="lg:col-span-1">
          <EarningsChart earnedInterest={poolData.earnedInterest} />
        </div>
      </div>

      {/* Additional Info */}
      <Card variant="standard" className="border-gray-200 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">
          How Lending Works
        </h3>
        <div className="space-y-3">
          <div className="flex items-start gap-3">
            <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/40 text-xs font-bold text-primary-600 dark:text-primary-400 flex-shrink-0">
              1
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Deposit USDT into the lending pool - your funds become available for borrowers
            </p>
          </div>
          <div className="flex items-start gap-3">
            <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/40 text-xs font-bold text-primary-600 dark:text-primary-400 flex-shrink-0">
              2
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Earn interest continuously based on pool utilization and borrower demand
            </p>
          </div>
          <div className="flex items-start gap-3">
            <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/40 text-xs font-bold text-primary-600 dark:text-primary-400 flex-shrink-0">
              3
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Withdraw your deposit plus earned interest at any time with no penalties
            </p>
          </div>
          <div className="flex items-start gap-3">
            <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/40 text-xs font-bold text-primary-600 dark:text-primary-400 flex-shrink-0">
              4
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Higher pool utilization means higher APY - rates adjust dynamically
            </p>
          </div>
        </div>
      </Card>
    </div>
  );
};

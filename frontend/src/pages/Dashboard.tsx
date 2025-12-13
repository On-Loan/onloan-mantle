import { useAccount } from 'wagmi';
import { Wallet, AlertCircle } from 'lucide-react';
import { ConnectButton } from '../components/wallet/ConnectButton';
import { useUserBalance } from '../hooks/useUserBalance';
import { PortfolioStats } from '../features/dashboard/PortfolioStats';
import { ActiveLoansCard } from '../features/dashboard/ActiveLoansCard';
import { EarningsCard } from '../features/dashboard/EarningsCard';
import { CreditScoreGauge } from '../features/dashboard/CreditScoreGauge';
import { QuickActions } from '../features/dashboard/QuickActions';

export const Dashboard = () => {
  const { isConnected } = useAccount();
  const userBalance = useUserBalance();

  if (!isConnected) {
    return (
      <div className="flex items-center justify-center min-h-[600px]">
        <div className="text-center max-w-md">
          <div className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/20">
            <Wallet className="h-10 w-10 text-primary-600 dark:text-primary-400" />
          </div>
          <h2 className="text-3xl font-bold text-gray-900 dark:text-gray-100 mb-4">
            Welcome to OnLoan
          </h2>
          <p className="text-gray-600 dark:text-gray-400 mb-8">
            Connect your wallet to access your lending and borrowing dashboard. View your portfolio,
            track earnings, and manage loans all in one place.
          </p>
          <ConnectButton />
          <div className="mt-8 p-4 rounded-xl bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800">
            <div className="flex items-start gap-2">
              <AlertCircle className="h-5 w-5 text-blue-600 dark:text-blue-400 mt-0.5 flex-shrink-0" />
              <div className="text-left">
                <p className="text-sm font-semibold text-blue-900 dark:text-blue-100 mb-1">
                  Testing on Mantle Sepolia
                </p>
                <p className="text-xs text-blue-700 dark:text-blue-300">
                  This is a testnet deployment. Use the faucet to get free test USDT for testing the protocol.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-4xl font-bold text-gray-900 dark:text-gray-100">Dashboard</h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Overview of your lending and borrowing activity
          </p>
        </div>
      </div>

      {/* Portfolio Stats */}
      <PortfolioStats userBalance={userBalance} />

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column - Loans & Earnings */}
        <div className="lg:col-span-2 space-y-6">
          <ActiveLoansCard userBalance={userBalance} />
          <EarningsCard userBalance={userBalance} />
        </div>

        {/* Right Column - Credit Score */}
        <div className="lg:col-span-1">
          <CreditScoreGauge userBalance={userBalance} />
        </div>
      </div>

      {/* Quick Actions */}
      <QuickActions />
    </div>
  );
};

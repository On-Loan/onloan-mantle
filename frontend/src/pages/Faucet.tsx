import { useAccount } from 'wagmi';
import { Wallet, Info, ExternalLink } from 'lucide-react';
import { Card } from '../components/ui';
import { useFaucet } from '../hooks/useFaucet';
import { ClaimCard } from '../features/faucet/ClaimCard';
import { ClaimTimer } from '../features/faucet/ClaimTimer';
import { FaucetStats } from '../features/faucet/FaucetStats';
import { ClaimHistory } from '../features/faucet/ClaimHistory';

export const Faucet = () => {
  const { isConnected } = useAccount();
  const faucetData = useFaucet();

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
                Connect your wallet to claim test USDT and start using OnLoan
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
            USDT Faucet
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Claim free testnet USDT to explore the OnLoan protocol
          </p>
        </div>
      </div>

      {/* Info Banner */}
      <Card variant="standard" className="border-blue-200 dark:border-blue-800 bg-blue-50 dark:bg-blue-900/20">
        <div className="flex items-start gap-3">
          <Info className="h-5 w-5 text-blue-600 dark:text-blue-400 flex-shrink-0 mt-0.5" />
          <div className="space-y-2">
            <p className="text-sm text-blue-900 dark:text-blue-100 font-medium">
              Welcome to the OnLoan Testnet Faucet!
            </p>
            <p className="text-sm text-blue-800 dark:text-blue-200">
              Claim 1,000 test USDT every 24 hours to try out lending, borrowing, and other features.
              This is testnet USDT with no real value. Need help?{' '}
              <a
                href="https://docs.onloan.xyz"
                target="_blank"
                rel="noopener noreferrer"
                className="font-medium underline inline-flex items-center gap-1 hover:text-blue-600 dark:hover:text-blue-300"
              >
                Read our docs
                <ExternalLink className="h-3 w-3" />
              </a>
            </p>
          </div>
        </div>
      </Card>

      {/* Current Balance */}
      <Card variant="standard" className="bg-gradient-to-br from-primary-50 to-primary-100 dark:from-primary-900/20 dark:to-primary-800/20 border-primary-200 dark:border-primary-800">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-primary-900 dark:text-primary-100 mb-1">
              Your USDT Balance
            </p>
            <p className="text-3xl font-bold text-primary-600 dark:text-primary-400">
              {Number(faucetData.usdtBalance).toLocaleString()} USDT
            </p>
          </div>
          <Wallet className="h-12 w-12 text-primary-600 dark:text-primary-400 opacity-50" />
        </div>
      </Card>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Claim Card */}
        <div>
          <ClaimCard
            faucetData={faucetData}
            onClaim={faucetData.claim}
            isPending={faucetData.isPending}
            isSuccess={faucetData.isSuccess}
            isError={faucetData.isError}
          />
        </div>

        {/* Timer */}
        <div>
          <ClaimTimer
            timeUntilNextClaim={faucetData.timeUntilNextClaim}
            canClaim={faucetData.canClaim}
          />
        </div>
      </div>

      {/* Stats */}
      <FaucetStats />

      {/* Claim History */}
      <ClaimHistory />

      {/* Additional Info */}
      <Card variant="standard" className="border-gray-200 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">
          How It Works
        </h3>
        <div className="space-y-3">
          <div className="flex items-start gap-3">
            <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/40 text-xs font-bold text-primary-600 dark:text-primary-400 flex-shrink-0">
              1
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Connect your wallet to the Mantle Sepolia testnet
            </p>
          </div>
          <div className="flex items-start gap-3">
            <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/40 text-xs font-bold text-primary-600 dark:text-primary-400 flex-shrink-0">
              2
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Click "Claim Now" to receive 1,000 test USDT instantly
            </p>
          </div>
          <div className="flex items-start gap-3">
            <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/40 text-xs font-bold text-primary-600 dark:text-primary-400 flex-shrink-0">
              3
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Wait 24 hours before claiming again (one claim per day)
            </p>
          </div>
          <div className="flex items-start gap-3">
            <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/40 text-xs font-bold text-primary-600 dark:text-primary-400 flex-shrink-0">
              4
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Use your test USDT to explore lending, borrowing, and earning features
            </p>
          </div>
        </div>
      </Card>
    </div>
  );
};

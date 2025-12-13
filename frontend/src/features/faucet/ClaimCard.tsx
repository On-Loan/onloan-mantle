import { Droplet, Loader2, CheckCircle, XCircle } from 'lucide-react';
import { Card, Button } from '../../components/ui';
import type { FaucetData } from '../../hooks/useFaucet';

interface ClaimCardProps {
  faucetData: FaucetData;
  onClaim: () => void;
  isPending: boolean;
  isSuccess: boolean;
  isError: boolean;
}

export const ClaimCard = ({ faucetData, onClaim, isPending, isSuccess, isError }: ClaimCardProps) => {
  const { canClaim, claimAmount, isLoading } = faucetData;

  if (isLoading) {
    return (
      <Card variant="elevated" className="text-center">
        <div className="py-12">
          <Loader2 className="h-12 w-12 text-primary-600 dark:text-primary-400 animate-spin mx-auto mb-4" />
          <p className="text-gray-600 dark:text-gray-400">Loading faucet data...</p>
        </div>
      </Card>
    );
  }

  return (
    <Card variant="elevated" className="text-center">
      <div className="py-8 space-y-6">
        {/* Icon */}
        <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-primary-100 to-primary-200 dark:from-primary-900/40 dark:to-primary-800/40">
          <Droplet className="h-10 w-10 text-primary-600 dark:text-primary-400" />
        </div>

        {/* Title */}
        <div>
          <h2 className="text-3xl font-bold text-gray-900 dark:text-gray-100 mb-2">
            Claim Test USDT
          </h2>
          <p className="text-gray-600 dark:text-gray-400">
            Get free testnet USDT to try out the OnLoan protocol
          </p>
        </div>

        {/* Claim Amount */}
        <div className="p-6 rounded-2xl bg-gradient-to-br from-primary-50 to-primary-100 dark:from-primary-900/20 dark:to-primary-800/20 border border-primary-200 dark:border-primary-800">
          <p className="text-sm font-medium text-primary-900 dark:text-primary-100 mb-2">
            Claim Amount
          </p>
          <p className="text-5xl font-bold text-primary-600 dark:text-primary-400">
            {Number(claimAmount).toLocaleString()} USDT
          </p>
        </div>

        {/* Claim Button */}
        <div className="space-y-3">
          <Button
            variant="primary"
            size="lg"
            fullWidth
            onClick={onClaim}
            disabled={!canClaim || isPending}
            loading={isPending}
          >
            {isPending ? 'Claiming...' : canClaim ? 'Claim Now' : 'Cooldown Active'}
          </Button>

          {/* Status Messages */}
          {isSuccess && (
            <div className="flex items-center justify-center gap-2 p-3 rounded-lg bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800">
              <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
              <p className="text-sm font-medium text-green-900 dark:text-green-100">
                Successfully claimed {claimAmount} USDT!
              </p>
            </div>
          )}

          {isError && (
            <div className="flex items-center justify-center gap-2 p-3 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800">
              <XCircle className="h-5 w-5 text-red-600 dark:text-red-400" />
              <p className="text-sm font-medium text-red-900 dark:text-red-100">
                Claim failed. Please try again.
              </p>
            </div>
          )}
        </div>

        {/* Info Text */}
        <div className="pt-4 border-t border-gray-200 dark:border-gray-800">
          <p className="text-xs text-gray-500 dark:text-gray-500">
            {canClaim
              ? 'You can claim once every 24 hours'
              : 'Wait for the cooldown to finish before claiming again'}
          </p>
        </div>
      </div>
    </Card>
  );
};

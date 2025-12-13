import { useState, useEffect } from 'react';
import { Card, Button, Input } from '../../components/ui';
import { Wallet, CheckCircle, AlertCircle, TrendingUp } from 'lucide-react';

interface DepositFormProps {
  usdtBalance: string;
  allowance: string;
  currentAPY: string;
  onApprove: (amount: string) => void;
  onDeposit: (amount: string) => void;
  isApprovePending: boolean;
  isApproveSuccess: boolean;
  isDepositPending: boolean;
  isDepositSuccess: boolean;
  isDepositError: boolean;
  refetchAllowance: () => void;
}

export const DepositForm = ({
  usdtBalance,
  allowance,
  currentAPY,
  onApprove,
  onDeposit,
  isApprovePending,
  isApproveSuccess,
  isDepositPending,
  isDepositSuccess,
  isDepositError,
  refetchAllowance,
}: DepositFormProps) => {
  const [amount, setAmount] = useState('');
  const [error, setError] = useState('');
  const [needsApproval, setNeedsApproval] = useState(false);

  // Check if approval is needed
  useEffect(() => {
    if (amount && Number(amount) > 0) {
      setNeedsApproval(Number(amount) > Number(allowance));
    } else {
      setNeedsApproval(false);
    }
  }, [amount, allowance]);

  // Refetch allowance after approval success
  useEffect(() => {
    if (isApproveSuccess) {
      setTimeout(() => {
        refetchAllowance();
      }, 1000);
    }
  }, [isApproveSuccess, refetchAllowance]);

  // Reset form after successful deposit
  useEffect(() => {
    if (isDepositSuccess) {
      setAmount('');
      setError('');
    }
  }, [isDepositSuccess]);

  const handleMaxClick = () => {
    setAmount(usdtBalance);
    setError('');
  };

  const validateAmount = () => {
    if (!amount || Number(amount) <= 0) {
      setError('Please enter a valid amount');
      return false;
    }
    if (Number(amount) > Number(usdtBalance)) {
      setError('Insufficient USDT balance');
      return false;
    }
    setError('');
    return true;
  };

  const handleApprove = () => {
    if (!validateAmount()) return;
    onApprove(amount);
  };

  const handleDeposit = () => {
    if (!validateAmount()) return;
    onDeposit(amount);
  };

  // Calculate projected earnings
  const calculateProjectedEarnings = () => {
    if (!amount || Number(amount) <= 0) return '0';
    const yearly = (Number(amount) * Number(currentAPY)) / 100;
    const monthly = yearly / 12;
    return monthly.toFixed(2);
  };

  return (
    <Card variant="elevated">
      <div className="space-y-6">
        {/* Header */}
        <div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
            Deposit USDT
          </h2>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Deposit USDT to earn interest and provide liquidity to borrowers
          </p>
        </div>

        {/* Balance Display */}
        <div className="p-4 rounded-xl bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Wallet className="h-5 w-5 text-gray-600 dark:text-gray-400" />
              <span className="text-sm text-gray-600 dark:text-gray-400">Your Balance</span>
            </div>
            <p className="text-lg font-bold text-gray-900 dark:text-gray-100">
              {Number(usdtBalance).toLocaleString()} USDT
            </p>
          </div>
        </div>

        {/* Amount Input */}
        <div className="space-y-2">
          <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
            Deposit Amount
          </label>
          <div className="relative">
            <Input
              type="number"
              placeholder="0.00"
              value={amount}
              onChange={(e) => {
                setAmount(e.target.value);
                setError('');
              }}
              className="pr-20"
            />
            <Button
              variant="ghost"
              size="sm"
              onClick={handleMaxClick}
              className="absolute right-2 top-1/2 -translate-y-1/2"
            >
              MAX
            </Button>
          </div>
          {error && (
            <div className="flex items-center gap-2 text-sm text-red-600 dark:text-red-400">
              <AlertCircle className="h-4 w-4" />
              <span>{error}</span>
            </div>
          )}
        </div>

        {/* APY Preview */}
        {amount && Number(amount) > 0 && (
          <div className="p-4 rounded-xl bg-gradient-to-br from-primary-50 to-primary-100 dark:from-primary-900/20 dark:to-primary-800/20 border border-primary-200 dark:border-primary-800">
            <div className="flex items-start gap-3">
              <TrendingUp className="h-5 w-5 text-primary-600 dark:text-primary-400 flex-shrink-0 mt-0.5" />
              <div className="space-y-2 flex-1">
                <p className="text-sm font-medium text-primary-900 dark:text-primary-100">
                  Projected Monthly Earnings
                </p>
                <p className="text-2xl font-bold text-primary-600 dark:text-primary-400">
                  ~{calculateProjectedEarnings()} USDT
                </p>
                <p className="text-xs text-primary-800 dark:text-primary-200">
                  Based on current APY of {currentAPY}% per year
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Action Buttons */}
        <div className="space-y-3">
          {needsApproval ? (
            <>
              <Button
                variant="primary"
                size="lg"
                fullWidth
                onClick={handleApprove}
                loading={isApprovePending}
                disabled={isApprovePending || !amount || Number(amount) <= 0}
              >
                {isApprovePending ? 'Approving...' : 'Approve USDT'}
              </Button>
              {isApproveSuccess && (
                <div className="flex items-center gap-2 p-3 rounded-lg bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800">
                  <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
                  <p className="text-sm text-green-900 dark:text-green-100">
                    Approval successful! Now you can deposit.
                  </p>
                </div>
              )}
            </>
          ) : (
            <Button
              variant="primary"
              size="lg"
              fullWidth
              onClick={handleDeposit}
              loading={isDepositPending}
              disabled={isDepositPending || !amount || Number(amount) <= 0}
            >
              {isDepositPending ? 'Depositing...' : 'Deposit USDT'}
            </Button>
          )}

          {isDepositSuccess && (
            <div className="flex items-center gap-2 p-3 rounded-lg bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800">
              <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
              <p className="text-sm text-green-900 dark:text-green-100">
                Deposit successful! Your funds are now earning interest.
              </p>
            </div>
          )}

          {isDepositError && (
            <div className="flex items-center gap-2 p-3 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800">
              <AlertCircle className="h-5 w-5 text-red-600 dark:text-red-400" />
              <p className="text-sm text-red-900 dark:text-red-100">
                Deposit failed. Please try again.
              </p>
            </div>
          )}
        </div>

        {/* Info */}
        <div className="pt-4 border-t border-gray-200 dark:border-gray-800">
          <p className="text-xs text-gray-500 dark:text-gray-500">
            Deposits are available for withdrawal at any time. Interest is calculated continuously and can be claimed separately.
          </p>
        </div>
      </div>
    </Card>
  );
};

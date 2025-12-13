import { useState, useEffect } from 'react';
import { Card, Button, Input } from '../../components/ui';
import { Wallet, CheckCircle, AlertCircle, AlertTriangle } from 'lucide-react';

interface WithdrawFormProps {
  totalDeposited: string;
  availableToWithdraw: string;
  earnedInterest: string;
  totalPoolLiquidity: string;
  onWithdraw: (amount: string) => void;
  isWithdrawPending: boolean;
  isWithdrawSuccess: boolean;
  isWithdrawError: boolean;
}

export const WithdrawForm = ({
  totalDeposited,
  availableToWithdraw,
  earnedInterest,
  totalPoolLiquidity,
  onWithdraw,
  isWithdrawPending,
  isWithdrawSuccess,
  isWithdrawError,
}: WithdrawFormProps) => {
  const [amount, setAmount] = useState('');
  const [error, setError] = useState('');
  const [showLiquidityWarning, setShowLiquidityWarning] = useState(false);

  // Reset form after successful withdrawal
  useEffect(() => {
    if (isWithdrawSuccess) {
      setAmount('');
      setError('');
      setShowLiquidityWarning(false);
    }
  }, [isWithdrawSuccess]);

  // Check liquidity warning
  useEffect(() => {
    if (amount && Number(amount) > 0) {
      const requestedAmount = Number(amount);
      const availableLiquidity = Number(totalPoolLiquidity);
      
      // Show warning if withdrawing more than 50% of pool liquidity
      setShowLiquidityWarning(requestedAmount > availableLiquidity * 0.5);
    } else {
      setShowLiquidityWarning(false);
    }
  }, [amount, totalPoolLiquidity]);

  const handleMaxClick = () => {
    setAmount(availableToWithdraw);
    setError('');
  };

  const validateAmount = () => {
    if (!amount || Number(amount) <= 0) {
      setError('Please enter a valid amount');
      return false;
    }
    if (Number(amount) > Number(availableToWithdraw)) {
      setError('Amount exceeds available balance');
      return false;
    }
    if (Number(amount) > Number(totalPoolLiquidity)) {
      setError('Insufficient pool liquidity');
      return false;
    }
    setError('');
    return true;
  };

  const handleWithdraw = () => {
    if (!validateAmount()) return;
    onWithdraw(amount);
  };

  return (
    <Card variant="elevated">
      <div className="space-y-6">
        {/* Header */}
        <div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
            Withdraw USDT
          </h2>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Withdraw your deposited USDT at any time
          </p>
        </div>

        {/* Balance Display */}
        <div className="space-y-3">
          <div className="p-4 rounded-xl bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Wallet className="h-5 w-5 text-gray-600 dark:text-gray-400" />
                <span className="text-sm text-gray-600 dark:text-gray-400">Total Deposited</span>
              </div>
              <p className="text-lg font-bold text-gray-900 dark:text-gray-100">
                {Number(totalDeposited).toLocaleString()} USDT
              </p>
            </div>
          </div>

          <div className="p-4 rounded-xl bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
                <span className="text-sm text-green-900 dark:text-green-100">Earned Interest</span>
              </div>
              <p className="text-lg font-bold text-green-600 dark:text-green-400">
                {Number(earnedInterest).toLocaleString()} USDT
              </p>
            </div>
          </div>
        </div>

        {/* Amount Input */}
        <div className="space-y-2">
          <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
            Withdraw Amount
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
          <p className="text-xs text-gray-500 dark:text-gray-500">
            Available: {Number(availableToWithdraw).toLocaleString()} USDT
          </p>
          {error && (
            <div className="flex items-center gap-2 text-sm text-red-600 dark:text-red-400">
              <AlertCircle className="h-4 w-4" />
              <span>{error}</span>
            </div>
          )}
        </div>

        {/* Liquidity Warning */}
        {showLiquidityWarning && (
          <div className="flex items-start gap-3 p-4 rounded-xl bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800">
            <AlertTriangle className="h-5 w-5 text-yellow-600 dark:text-yellow-400 flex-shrink-0 mt-0.5" />
            <div className="space-y-1">
              <p className="text-sm font-medium text-yellow-900 dark:text-yellow-100">
                Large Withdrawal Notice
              </p>
              <p className="text-xs text-yellow-800 dark:text-yellow-200">
                This withdrawal represents a significant portion of pool liquidity. Pool utilization may increase temporarily.
              </p>
            </div>
          </div>
        )}

        {/* Pool Liquidity Info */}
        <div className="p-4 rounded-xl bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800">
          <div className="flex items-center justify-between">
            <span className="text-sm text-blue-900 dark:text-blue-100">Pool Liquidity</span>
            <p className="text-sm font-bold text-blue-600 dark:text-blue-400">
              {Number(totalPoolLiquidity).toLocaleString()} USDT
            </p>
          </div>
        </div>

        {/* Action Button */}
        <div className="space-y-3">
          <Button
            variant="primary"
            size="lg"
            fullWidth
            onClick={handleWithdraw}
            loading={isWithdrawPending}
            disabled={isWithdrawPending || !amount || Number(amount) <= 0}
          >
            {isWithdrawPending ? 'Withdrawing...' : 'Withdraw USDT'}
          </Button>

          {isWithdrawSuccess && (
            <div className="flex items-center gap-2 p-3 rounded-lg bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800">
              <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
              <p className="text-sm text-green-900 dark:text-green-100">
                Withdrawal successful! Funds have been sent to your wallet.
              </p>
            </div>
          )}

          {isWithdrawError && (
            <div className="flex items-center gap-2 p-3 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800">
              <AlertCircle className="h-5 w-5 text-red-600 dark:text-red-400" />
              <p className="text-sm text-red-900 dark:text-red-100">
                Withdrawal failed. Please try again.
              </p>
            </div>
          )}
        </div>

        {/* Info */}
        <div className="pt-4 border-t border-gray-200 dark:border-gray-800">
          <p className="text-xs text-gray-500 dark:text-gray-500">
            Withdrawals are instant and will be sent directly to your connected wallet. Earned interest is included in your available balance.
          </p>
        </div>
      </div>
    </Card>
  );
};

import { FileText, Clock, AlertCircle } from 'lucide-react';
import { Card, Button } from '../../components/ui';
import { Link } from 'react-router-dom';
import type { UserBalance } from '../../hooks/useUserBalance';

interface ActiveLoansCardProps {
  userBalance: UserBalance;
}

export const ActiveLoansCard = ({ userBalance }: ActiveLoansCardProps) => {
  const { activeLoans, totalBorrowed, isLoading } = userBalance;

  if (isLoading) {
    return (
      <Card variant="elevated" title="Active Loans" icon={FileText}>
        <div className="animate-pulse space-y-4">
          <div className="h-16 bg-gray-200 dark:bg-gray-700 rounded"></div>
          <div className="h-16 bg-gray-200 dark:bg-gray-700 rounded"></div>
        </div>
      </Card>
    );
  }

  if (activeLoans === 0) {
    return (
      <Card variant="elevated" title="Active Loans" icon={FileText}>
        <div className="text-center py-8">
          <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-gray-100 dark:bg-gray-800">
            <FileText className="h-8 w-8 text-gray-400" />
          </div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2">
            No Active Loans
          </h3>
          <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
            You don't have any active loans yet. Start borrowing to access liquidity.
          </p>
          <Link to="/borrow">
            <Button variant="primary" size="sm">
              Borrow Now
            </Button>
          </Link>
        </div>
      </Card>
    );
  }

  return (
    <Card variant="elevated" title="Active Loans" icon={FileText}>
      <div className="space-y-4">
        <div className="flex items-center justify-between p-4 rounded-xl bg-gray-50 dark:bg-gray-800">
          <div>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Total Borrowed</p>
            <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
              ${Number(totalBorrowed).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
            </p>
          </div>
          <div className="text-right">
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Active Loans</p>
            <p className="text-2xl font-bold text-primary-600 dark:text-primary-400">
              {activeLoans}
            </p>
          </div>
        </div>

        <div className="space-y-3">
          {Array.from({ length: Math.min(activeLoans, 3) }).map((_, i) => (
            <div
              key={i}
              className="flex items-center justify-between p-3 rounded-lg border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary-100 dark:bg-primary-900/20">
                  <FileText className="h-5 w-5 text-primary-600 dark:text-primary-400" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                    Personal Loan #{i + 1}
                  </p>
                  <p className="text-xs text-gray-600 dark:text-gray-400">
                    $<span className="font-mono">{(Number(totalBorrowed) / activeLoans).toFixed(2)}</span> at 8% APR
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2 text-xs text-amber-600 dark:text-amber-400">
                <Clock className="h-4 w-4" />
                <span>{30 - i * 5} days left</span>
              </div>
            </div>
          ))}
        </div>

        {activeLoans > 3 && (
          <Link to="/my-loans">
            <Button variant="ghost" size="sm" fullWidth>
              View All Loans ({activeLoans})
            </Button>
          </Link>
        )}

        <div className="flex items-start gap-2 p-3 rounded-lg bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800">
          <AlertCircle className="h-4 w-4 text-amber-600 dark:text-amber-400 mt-0.5 flex-shrink-0" />
          <p className="text-xs text-amber-800 dark:text-amber-200">
            Remember to make timely repayments to maintain your credit score and avoid liquidation.
          </p>
        </div>
      </div>
    </Card>
  );
};

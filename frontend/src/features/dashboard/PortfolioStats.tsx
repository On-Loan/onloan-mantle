import { TrendingUp, DollarSign, PiggyBank, Wallet } from 'lucide-react';
import { Card } from '../../components/ui';
import type { UserBalance } from '../../hooks/useUserBalance';

interface PortfolioStatsProps {
  userBalance: UserBalance;
}

export const PortfolioStats = ({ userBalance }: PortfolioStatsProps) => {
  const { totalDeposited, earnedInterest, totalBorrowed, availableToWithdraw, isLoading } = userBalance;

  const stats = [
    {
      title: 'Total Deposited',
      value: `$${Number(totalDeposited).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
      icon: PiggyBank,
      change: '+12.5%',
      changeType: 'positive' as const,
    },
    {
      title: 'Total Borrowed',
      value: `$${Number(totalBorrowed).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
      icon: DollarSign,
      change: '-',
      changeType: 'neutral' as const,
    },
    {
      title: 'Interest Earned',
      value: `$${Number(earnedInterest).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
      icon: TrendingUp,
      change: '+8.2%',
      changeType: 'positive' as const,
    },
    {
      title: 'Available to Withdraw',
      value: `$${Number(availableToWithdraw).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
      icon: Wallet,
      change: '-',
      changeType: 'neutral' as const,
    },
  ];

  if (isLoading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {[1, 2, 3, 4].map((i) => (
          <div key={i} className="animate-pulse">
            <Card variant="elevated" className="h-32">
              <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-24 mb-4"></div>
              <div className="h-8 bg-gray-300 dark:bg-gray-600 rounded w-32 mb-2"></div>
              <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
            </Card>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      {stats.map((stat) => {
        const Icon = stat.icon;
        return (
          <Card key={stat.title} variant="elevated" className="hover:shadow-xl transition-shadow">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 dark:text-gray-400 mb-2">
                  {stat.title}
                </p>
                <p className="text-3xl font-bold text-gray-900 dark:text-gray-100 mb-2">
                  {stat.value}
                </p>
                <div className="flex items-center gap-1">
                  <span
                    className={`text-xs font-medium ${
                      stat.changeType === 'positive'
                        ? 'text-green-600 dark:text-green-400'
                        : stat.changeType === 'neutral'
                        ? 'text-gray-600 dark:text-gray-400'
                        : 'text-red-600 dark:text-red-400'
                    }`}
                  >
                    {stat.change}
                  </span>
                  <span className="text-xs text-gray-500 dark:text-gray-500">vs last month</span>
                </div>
              </div>
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary-100 dark:bg-primary-900/20">
                <Icon className="h-6 w-6 text-primary-600 dark:text-primary-400" />
              </div>
            </div>
          </Card>
        );
      })}
    </div>
  );
};

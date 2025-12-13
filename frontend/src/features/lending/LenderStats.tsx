import { PiggyBank, TrendingUp, Percent, PieChart } from 'lucide-react';
import { Card } from '../../components/ui';

interface LenderStatsProps {
  totalDeposited: string;
  earnedInterest: string;
  currentAPY: string;
  poolShare: string;
  isLoading: boolean;
}

export const LenderStats = ({
  totalDeposited,
  earnedInterest,
  currentAPY,
  poolShare,
  isLoading,
}: LenderStatsProps) => {
  const stats = [
    {
      title: 'Total Deposited',
      value: `${Number(totalDeposited).toLocaleString()} USDT`,
      icon: PiggyBank,
      color: 'text-blue-600 dark:text-blue-400',
      bg: 'bg-blue-100 dark:bg-blue-900/20',
      change: '+12.5%',
      changePositive: true,
    },
    {
      title: 'Interest Earned',
      value: `${Number(earnedInterest).toLocaleString()} USDT`,
      icon: TrendingUp,
      color: 'text-green-600 dark:text-green-400',
      bg: 'bg-green-100 dark:bg-green-900/20',
      change: '+8.2%',
      changePositive: true,
    },
    {
      title: 'Current APY',
      value: `${currentAPY}%`,
      icon: Percent,
      color: 'text-purple-600 dark:text-purple-400',
      bg: 'bg-purple-100 dark:bg-purple-900/20',
      change: 'Variable',
      changePositive: true,
    },
    {
      title: 'Pool Share',
      value: `${poolShare}%`,
      icon: PieChart,
      color: 'text-orange-600 dark:text-orange-400',
      bg: 'bg-orange-100 dark:bg-orange-900/20',
      change: 'of total pool',
      changePositive: true,
    },
  ];

  if (isLoading) {
    return (
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {[...Array(4)].map((_, i) => (
          <Card key={i} variant="standard">
            <div className="animate-pulse space-y-3">
              <div className="flex items-center gap-3">
                <div className="h-12 w-12 rounded-xl bg-gray-200 dark:bg-gray-700" />
                <div className="flex-1 space-y-2">
                  <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-24" />
                  <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-32" />
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {stats.map((stat) => {
        const Icon = stat.icon;
        return (
          <Card
            key={stat.title}
            variant="elevated"
            className="hover:shadow-lg transition-shadow"
          >
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className={`flex h-12 w-12 items-center justify-center rounded-xl ${stat.bg}`}>
                  <Icon className={`h-6 w-6 ${stat.color}`} />
                </div>
              </div>
              <div>
                <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">
                  {stat.title}
                </p>
                <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                  {stat.value}
                </p>
                <p className={`text-xs mt-1 ${
                  stat.changePositive 
                    ? 'text-green-600 dark:text-green-400' 
                    : 'text-gray-500 dark:text-gray-500'
                }`}>
                  {stat.change}
                </p>
              </div>
            </div>
          </Card>
        );
      })}
    </div>
  );
};

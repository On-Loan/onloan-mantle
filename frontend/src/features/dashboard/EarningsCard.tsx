import { TrendingUp } from 'lucide-react';
import { Card } from '../../components/ui';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import type { UserBalance } from '../../hooks/useUserBalance';

interface EarningsCardProps {
  userBalance: UserBalance;
}

const mockChartData = [
  { month: 'Jan', earnings: 0 },
  { month: 'Feb', earnings: 45 },
  { month: 'Mar', earnings: 112 },
  { month: 'Apr', earnings: 189 },
  { month: 'May', earnings: 267 },
  { month: 'Jun', earnings: 342 },
];

export const EarningsCard = ({ userBalance }: EarningsCardProps) => {
  const { earnedInterest, isLoading } = userBalance;

  if (isLoading) {
    return (
      <Card variant="elevated" title="Interest Earned" icon={TrendingUp}>
        <div className="animate-pulse space-y-4">
          <div className="h-24 bg-gray-200 dark:bg-gray-700 rounded"></div>
          <div className="h-32 bg-gray-200 dark:bg-gray-700 rounded"></div>
        </div>
      </Card>
    );
  }

  const currentEarnings = Number(earnedInterest);
  const projectedMonthly = currentEarnings * 0.08; // 8% estimated monthly

  return (
    <Card variant="elevated" title="Interest Earned" icon={TrendingUp}>
      <div className="space-y-6">
        {/* Current Earnings */}
        <div className="flex items-end justify-between">
          <div>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-2">Total Interest Earned</p>
            <p className="text-4xl font-bold text-gray-900 dark:text-gray-100">
              ${currentEarnings.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
            </p>
          </div>
          <div className="text-right">
            <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">Projected Monthly</p>
            <p className="text-lg font-semibold text-green-600 dark:text-green-400">
              +${projectedMonthly.toFixed(2)}
            </p>
          </div>
        </div>

        {/* APY Display */}
        <div className="grid grid-cols-3 gap-4">
          <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-800">
            <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">Current APY</p>
            <p className="text-xl font-bold text-primary-600 dark:text-primary-400">8.5%</p>
          </div>
          <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-800">
            <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">Avg APY</p>
            <p className="text-xl font-bold text-gray-900 dark:text-gray-100">7.2%</p>
          </div>
          <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-800">
            <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">Best APY</p>
            <p className="text-xl font-bold text-green-600 dark:text-green-400">10.1%</p>
          </div>
        </div>

        {/* Earnings Chart */}
        <div>
          <p className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
            Earnings Trend (6 Months)
          </p>
          <ResponsiveContainer width="100%" height={140}>
            <LineChart data={mockChartData}>
              <XAxis
                dataKey="month"
                stroke="#9CA3AF"
                fontSize={12}
                tickLine={false}
                axisLine={false}
              />
              <YAxis
                stroke="#9CA3AF"
                fontSize={12}
                tickLine={false}
                axisLine={false}
                tickFormatter={(value) => `$${value}`}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'rgba(255, 255, 255, 0.95)',
                  border: '1px solid #E5E7EB',
                  borderRadius: '8px',
                  padding: '8px',
                }}
                formatter={(value) => [`$${value}`, 'Earnings']}
              />
              <Line
                type="monotone"
                dataKey="earnings"
                stroke="#7c3aed"
                strokeWidth={2}
                dot={{ fill: '#7c3aed', r: 4 }}
                activeDot={{ r: 6 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Next Interest Payment */}
        <div className="p-4 rounded-xl bg-gradient-to-r from-primary-50 to-primary-100 dark:from-primary-900/20 dark:to-primary-800/20 border border-primary-200 dark:border-primary-800">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-primary-900 dark:text-primary-100 mb-1">
                Next Interest Payment
              </p>
              <p className="text-xs text-primary-700 dark:text-primary-300">
                Estimated in 7 days
              </p>
            </div>
            <p className="text-2xl font-bold text-primary-600 dark:text-primary-400">
              +${projectedMonthly.toFixed(2)}
            </p>
          </div>
        </div>
      </div>
    </Card>
  );
};

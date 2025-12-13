import { Card } from '../../components/ui';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { TrendingUp } from 'lucide-react';

interface EarningsChartProps {
  earnedInterest: string;
}

export const EarningsChart = ({ earnedInterest }: EarningsChartProps) => {
  // Mock data - in production, fetch historical earnings from contract events or backend
  const mockData = [
    { month: 'Jul', earnings: 0 },
    { month: 'Aug', earnings: 45 },
    { month: 'Sep', earnings: 112 },
    { month: 'Oct', earnings: 198 },
    { month: 'Nov', earnings: 301 },
    { month: 'Dec', earnings: Number(earnedInterest) || 425 },
  ];

  return (
    <Card variant="elevated">
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-start justify-between">
          <div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-gray-100 mb-2">
              Interest Earnings
            </h3>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Your interest accumulation over time
            </p>
          </div>
          <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-green-100 dark:bg-green-900/20">
            <TrendingUp className="h-6 w-6 text-green-600 dark:text-green-400" />
          </div>
        </div>

        {/* Total Earned */}
        <div className="p-4 rounded-xl bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20 border border-green-200 dark:border-green-800">
          <p className="text-sm font-medium text-green-900 dark:text-green-100 mb-1">
            Total Interest Earned
          </p>
          <p className="text-3xl font-bold text-green-600 dark:text-green-400">
            {Number(earnedInterest).toLocaleString()} USDT
          </p>
        </div>

        {/* Chart */}
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={mockData}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-gray-200 dark:stroke-gray-700" />
              <XAxis 
                dataKey="month" 
                className="text-xs"
                tick={{ fill: 'currentColor' }}
              />
              <YAxis 
                className="text-xs"
                tick={{ fill: 'currentColor' }}
                label={{ value: 'USDT', angle: -90, position: 'insideLeft' }}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'rgba(255, 255, 255, 0.95)',
                  border: '1px solid #e5e7eb',
                  borderRadius: '8px',
                  padding: '8px 12px',
                }}
                labelStyle={{ color: '#111827', fontWeight: 'bold' }}
                itemStyle={{ color: '#059669' }}
              />
              <Line
                type="monotone"
                dataKey="earnings"
                stroke="#059669"
                strokeWidth={2}
                dot={{ fill: '#059669', r: 4 }}
                activeDot={{ r: 6 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* APY Info */}
        <div className="grid grid-cols-3 gap-3">
          <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-800 text-center">
            <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">Current APY</p>
            <p className="text-lg font-bold text-gray-900 dark:text-gray-100">8.5%</p>
          </div>
          <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-800 text-center">
            <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">Avg APY</p>
            <p className="text-lg font-bold text-gray-900 dark:text-gray-100">7.2%</p>
          </div>
          <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-800 text-center">
            <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">Best APY</p>
            <p className="text-lg font-bold text-gray-900 dark:text-gray-100">10.1%</p>
          </div>
        </div>

        {/* Info */}
        <div className="pt-4 border-t border-gray-200 dark:border-gray-800">
          <p className="text-xs text-gray-500 dark:text-gray-500">
            Interest is calculated continuously based on pool utilization. Higher utilization results in higher APY for lenders.
          </p>
        </div>
      </div>
    </Card>
  );
};

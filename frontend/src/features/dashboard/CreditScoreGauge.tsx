import { Shield, TrendingUp, AlertTriangle, CheckCircle } from 'lucide-react';
import { Card } from '../../components/ui';
import type { UserBalance } from '../../hooks/useUserBalance';

interface CreditScoreGaugeProps {
  userBalance: UserBalance;
}

const getCreditTier = (score: number) => {
  if (score >= 750) return { tier: 'Excellent', color: 'text-green-600 dark:text-green-400', bg: 'bg-green-100 dark:bg-green-900/20' };
  if (score >= 650) return { tier: 'Good', color: 'text-blue-600 dark:text-blue-400', bg: 'bg-blue-100 dark:bg-blue-900/20' };
  if (score >= 550) return { tier: 'Fair', color: 'text-yellow-600 dark:text-yellow-400', bg: 'bg-yellow-100 dark:bg-yellow-900/20' };
  return { tier: 'Poor', color: 'text-red-600 dark:text-red-400', bg: 'bg-red-100 dark:bg-red-900/20' };
};

const getScorePercentage = (score: number) => {
  const min = 300;
  const max = 850;
  return ((score - min) / (max - min)) * 100;
};

export const CreditScoreGauge = ({ userBalance }: CreditScoreGaugeProps) => {
  const { creditScore, isLoading } = userBalance;

  if (isLoading) {
    return (
      <Card variant="elevated" title="Credit Score" icon={Shield}>
        <div className="animate-pulse space-y-4">
          <div className="h-48 bg-gray-200 dark:bg-gray-700 rounded-full"></div>
          <div className="h-16 bg-gray-200 dark:bg-gray-700 rounded"></div>
        </div>
      </Card>
    );
  }

  const { tier, color, bg } = getCreditTier(creditScore);
  const percentage = getScorePercentage(creditScore);

  return (
    <Card variant="elevated" title="Credit Score" icon={Shield}>
      <div className="space-y-6">
        {/* Score Display */}
        <div className="text-center">
          <div className="relative mx-auto w-48 h-48 mb-4">
            {/* Background Circle */}
            <svg className="transform -rotate-90 w-48 h-48">
              <circle
                cx="96"
                cy="96"
                r="88"
                stroke="currentColor"
                strokeWidth="12"
                fill="transparent"
                className="text-gray-200 dark:text-gray-700"
              />
              {/* Progress Circle */}
              <circle
                cx="96"
                cy="96"
                r="88"
                stroke="currentColor"
                strokeWidth="12"
                fill="transparent"
                strokeDasharray={`${2 * Math.PI * 88}`}
                strokeDashoffset={`${2 * Math.PI * 88 * (1 - percentage / 100)}`}
                className="text-primary-600 dark:text-primary-400 transition-all duration-1000"
                strokeLinecap="round"
              />
            </svg>
            {/* Score Number */}
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <p className="text-5xl font-bold text-gray-900 dark:text-gray-100">{creditScore}</p>
              <p className={`text-sm font-semibold mt-1 ${color}`}>{tier}</p>
            </div>
          </div>

          <div className="flex items-center justify-center gap-2 mb-4">
            {creditScore >= 650 ? (
              <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
            ) : (
              <AlertTriangle className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />
            )}
            <p className="text-sm text-gray-600 dark:text-gray-400">
              {creditScore >= 650 ? 'Eligible for better rates' : 'Improve score for better rates'}
            </p>
          </div>
        </div>

        {/* Score Breakdown */}
        <div className="space-y-3">
          <ScoreFactorBar
            label="On-time Payments"
            value={85}
            color="bg-green-500"
            icon={<CheckCircle className="h-4 w-4" />}
          />
          <ScoreFactorBar
            label="Loan History"
            value={creditScore >= 400 ? 70 : 40}
            color="bg-blue-500"
            icon={<TrendingUp className="h-4 w-4" />}
          />
          <ScoreFactorBar
            label="Utilization Rate"
            value={60}
            color="bg-purple-500"
            icon={<Shield className="h-4 w-4" />}
          />
        </div>

        {/* Credit Tier Benefits */}
        <div className={`p-4 rounded-xl ${bg} border border-gray-200 dark:border-gray-700`}>
          <p className="text-sm font-semibold text-gray-900 dark:text-gray-100 mb-2">
            Your Benefits
          </p>
          <ul className="space-y-1 text-xs text-gray-700 dark:text-gray-300">
            <li className="flex items-center gap-2">
              <CheckCircle className="h-3 w-3 text-green-600 dark:text-green-400" />
              <span>{creditScore >= 650 ? 'Lower interest rates' : 'Standard rates'}</span>
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle className="h-3 w-3 text-green-600 dark:text-green-400" />
              <span>{creditScore >= 700 ? 'Higher loan limits' : 'Standard loan limits'}</span>
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle className="h-3 w-3 text-green-600 dark:text-green-400" />
              <span>{creditScore >= 750 ? 'Priority support' : 'Standard support'}</span>
            </li>
          </ul>
        </div>

        {/* Next Tier */}
        {creditScore < 850 && (
          <div className="text-center pt-2">
            <p className="text-xs text-gray-600 dark:text-gray-400">
              {creditScore < 550 && `${550 - creditScore} points to Fair`}
              {creditScore >= 550 && creditScore < 650 && `${650 - creditScore} points to Good`}
              {creditScore >= 650 && creditScore < 750 && `${750 - creditScore} points to Excellent`}
              {creditScore >= 750 && 'Congratulations! You have an excellent score'}
            </p>
          </div>
        )}
      </div>
    </Card>
  );
};

const ScoreFactorBar = ({
  label,
  value,
  color,
  icon,
}: {
  label: string;
  value: number;
  color: string;
  icon: React.ReactNode;
}) => {
  return (
    <div>
      <div className="flex items-center justify-between mb-1">
        <div className="flex items-center gap-2">
          <div className="text-gray-600 dark:text-gray-400">{icon}</div>
          <span className="text-xs font-medium text-gray-700 dark:text-gray-300">{label}</span>
        </div>
        <span className="text-xs font-semibold text-gray-900 dark:text-gray-100">{value}%</span>
      </div>
      <div className="h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
        <div
          className={`h-full ${color} transition-all duration-500`}
          style={{ width: `${value}%` }}
        />
      </div>
    </div>
  );
};

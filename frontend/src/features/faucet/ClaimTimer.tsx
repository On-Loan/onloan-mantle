import { Clock } from 'lucide-react';
import { Card } from '../../components/ui';

interface ClaimTimerProps {
  timeUntilNextClaim: number;
  canClaim: boolean;
}

export const ClaimTimer = ({ timeUntilNextClaim, canClaim }: ClaimTimerProps) => {
  const formatTime = (seconds: number) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    if (hours > 0) {
      return `${hours}h ${minutes}m ${secs}s`;
    } else if (minutes > 0) {
      return `${minutes}m ${secs}s`;
    } else {
      return `${secs}s`;
    }
  };

  const getProgress = () => {
    const totalCooldown = 24 * 60 * 60; // 24 hours
    const elapsed = totalCooldown - timeUntilNextClaim;
    return (elapsed / totalCooldown) * 100;
  };

  if (canClaim) {
    return (
      <Card variant="standard" className="text-center">
        <div className="py-6">
          <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/20">
            <Clock className="h-8 w-8 text-green-600 dark:text-green-400" />
          </div>
          <h3 className="text-xl font-bold text-green-600 dark:text-green-400 mb-2">
            Ready to Claim!
          </h3>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            You can claim your test USDT now
          </p>
        </div>
      </Card>
    );
  }

  return (
    <Card variant="standard">
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Clock className="h-5 w-5 text-gray-600 dark:text-gray-400" />
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
              Next Claim In
            </h3>
          </div>
          <div className="text-right">
            <p className="text-2xl font-bold text-primary-600 dark:text-primary-400 font-mono">
              {formatTime(timeUntilNextClaim)}
            </p>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="space-y-2">
          <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-primary-500 to-primary-600 transition-all duration-1000"
              style={{ width: `${getProgress()}%` }}
            />
          </div>
          <div className="flex justify-between text-xs text-gray-600 dark:text-gray-400">
            <span>Cooldown Period</span>
            <span>{Math.round(getProgress())}% Complete</span>
          </div>
        </div>

        {/* Time Breakdown */}
        <div className="grid grid-cols-3 gap-3 pt-2">
          <div className="text-center p-3 rounded-lg bg-gray-50 dark:bg-gray-800">
            <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
              {Math.floor(timeUntilNextClaim / 3600)}
            </p>
            <p className="text-xs text-gray-600 dark:text-gray-400">Hours</p>
          </div>
          <div className="text-center p-3 rounded-lg bg-gray-50 dark:bg-gray-800">
            <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
              {Math.floor((timeUntilNextClaim % 3600) / 60)}
            </p>
            <p className="text-xs text-gray-600 dark:text-gray-400">Minutes</p>
          </div>
          <div className="text-center p-3 rounded-lg bg-gray-50 dark:bg-gray-800">
            <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
              {timeUntilNextClaim % 60}
            </p>
            <p className="text-xs text-gray-600 dark:text-gray-400">Seconds</p>
          </div>
        </div>
      </div>
    </Card>
  );
};

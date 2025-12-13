import { ExternalLink, CheckCircle } from 'lucide-react';
import { Card } from '../../components/ui';

interface ClaimRecord {
  timestamp: number;
  amount: string;
  txHash: string;
}

export const ClaimHistory = () => {
  // Mock data - in production, fetch from contract events
  const mockHistory: ClaimRecord[] = [
    {
      timestamp: Date.now() - 25 * 60 * 60 * 1000, // 25 hours ago
      amount: '1,000',
      txHash: '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    },
    {
      timestamp: Date.now() - 49 * 60 * 60 * 1000, // 49 hours ago
      amount: '1,000',
      txHash: '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
    },
  ];

  const formatTimestamp = (timestamp: number) => {
    const date = new Date(timestamp);
    const now = Date.now();
    const diff = now - timestamp;
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(hours / 24);

    if (days > 0) {
      return `${days} day${days > 1 ? 's' : ''} ago`;
    } else {
      return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    }
  };

  const formatTxHash = (hash: string) => {
    return `${hash.slice(0, 6)}...${hash.slice(-4)}`;
  };

  if (mockHistory.length === 0) {
    return (
      <Card variant="standard">
        <div className="text-center py-12">
          <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-gray-100 dark:bg-gray-800">
            <CheckCircle className="h-8 w-8 text-gray-400" />
          </div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2">
            No Claims Yet
          </h3>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Your claim history will appear here after your first claim
          </p>
        </div>
      </Card>
    );
  }

  return (
    <Card variant="standard">
      <h3 className="text-xl font-bold text-gray-900 dark:text-gray-100 mb-6">Claim History</h3>
      <div className="space-y-3">
        {mockHistory.map((claim, index) => (
          <div
            key={index}
            className="flex items-center justify-between p-4 rounded-xl border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 transition-colors"
          >
            <div className="flex items-center gap-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-green-100 dark:bg-green-900/20">
                <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
              </div>
              <div>
                <p className="text-sm font-semibold text-gray-900 dark:text-gray-100">
                  Claimed {claim.amount} USDT
                </p>
                <p className="text-xs text-gray-600 dark:text-gray-400">
                  {formatTimestamp(claim.timestamp)}
                </p>
              </div>
            </div>
            <a
              href={`https://sepolia.mantlescan.xyz/tx/${claim.txHash}`}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 text-sm font-medium text-primary-600 dark:text-primary-400 hover:underline"
            >
              <span className="font-mono">{formatTxHash(claim.txHash)}</span>
              <ExternalLink className="h-4 w-4" />
            </a>
          </div>
        ))}
      </div>
    </Card>
  );
};

import { useAccount, useBalance } from 'wagmi';
import { Wallet, Copy, ExternalLink } from 'lucide-react';
import { Card } from '../ui';
import { useState } from 'react';

export const WalletInfo = () => {
  const { address, isConnected } = useAccount();
  const { data: balance } = useBalance({ address });
  const [copied, setCopied] = useState(false);

  const copyAddress = () => {
    if (address) {
      navigator.clipboard.writeText(address);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  if (!isConnected || !address) {
    return null;
  }

  const shortAddress = `${address.slice(0, 6)}...${address.slice(-4)}`;

  return (
    <Card variant="standard" className="max-w-md">
      <div className="flex items-center gap-3 mb-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/20">
          <Wallet className="h-5 w-5 text-primary-600 dark:text-primary-400" />
        </div>
        <div>
          <h3 className="text-sm font-medium text-gray-600 dark:text-gray-400">
            Connected Wallet
          </h3>
          <div className="flex items-center gap-2">
            <span className="font-mono text-sm font-semibold text-gray-900 dark:text-gray-100">
              {shortAddress}
            </span>
            <button
              onClick={copyAddress}
              className="text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
              title="Copy address"
            >
              <Copy className="h-4 w-4" />
            </button>
            <a
              href={`https://sepolia.mantlescan.xyz/address/${address}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
              title="View on explorer"
            >
              <ExternalLink className="h-4 w-4" />
            </a>
          </div>
          {copied && (
            <span className="text-xs text-green-600 dark:text-green-400">Copied!</span>
          )}
        </div>
      </div>

      <div className="space-y-2">
        <div className="flex justify-between">
          <span className="text-sm text-gray-600 dark:text-gray-400">Balance</span>
          <span className="font-mono text-sm font-semibold text-gray-900 dark:text-gray-100">
            {balance ? `${Number(balance.value) / 1e18} ${balance.symbol}` : 'Loading...'}
          </span>
        </div>
        <div className="flex justify-between">
          <span className="text-sm text-gray-600 dark:text-gray-400">Network</span>
          <span className="text-sm font-medium text-gray-900 dark:text-gray-100">
            Mantle Sepolia
          </span>
        </div>
      </div>
    </Card>
  );
};

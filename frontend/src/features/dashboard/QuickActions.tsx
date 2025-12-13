import React from 'react';
import { TrendingUp, HandCoins, Droplet, ArrowRight } from 'lucide-react';
import { Button, Card } from '../../components/ui';
import { Link } from 'react-router-dom';

export const QuickActions = (): React.ReactElement => {
  const actions = [
    {
      title: 'Deposit & Earn',
      description: 'Start earning competitive APY on your USDT deposits',
      icon: TrendingUp,
      iconBg: 'bg-green-100 dark:bg-green-900/20',
      iconColor: 'text-green-600 dark:text-green-400',
      buttonText: 'Lend Now',
      buttonVariant: 'primary' as const,
      link: '/lend',
    },
    {
      title: 'Borrow USDT',
      description: 'Access instant liquidity against your collateral',
      icon: HandCoins,
      iconBg: 'bg-blue-100 dark:bg-blue-900/20',
      iconColor: 'text-blue-600 dark:text-blue-400',
      buttonText: 'Borrow Now',
      buttonVariant: 'secondary' as const,
      link: '/borrow',
    },
    {
      title: 'Get Test USDT',
      description: 'Claim free testnet USDT to start testing the protocol',
      icon: Droplet,
      iconBg: 'bg-purple-100 dark:bg-purple-900/20',
      iconColor: 'text-purple-600 dark:text-purple-400',
      buttonText: 'Visit Faucet',
      buttonVariant: 'ghost' as const,
      link: '/faucet',
    },
  ];

  return (
    <Card variant="standard" className="lg:col-span-2">
      <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100 mb-6">Quick Actions</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {actions.map((action) => {
          const Icon = action.icon;
          return (
            <div
              key={action.title}
              className="p-5 rounded-xl border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 transition-all hover:shadow-md"
            >
              <div className={`flex h-12 w-12 items-center justify-center rounded-xl ${action.iconBg} mb-4`}>
                <Icon className={`h-6 w-6 ${action.iconColor}`} />
              </div>
              <h3 className="text-base font-semibold text-gray-900 dark:text-gray-100 mb-2">
                {action.title}
              </h3>
              <p className="text-sm text-gray-600 dark:text-gray-400 mb-4 min-h-[40px]">
                {action.description}
              </p>
              <Link to={action.link}>
                <Button variant={action.buttonVariant} size="sm" fullWidth>
                  {action.buttonText}
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </Link>
            </div>
          );
        })}
      </div>

      {/* Additional Info */}
      <div className="mt-6 p-4 rounded-xl bg-gradient-to-r from-primary-50 to-primary-100 dark:from-primary-900/20 dark:to-primary-800/20 border border-primary-200 dark:border-primary-800">
        <div className="flex items-start gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary-600 dark:bg-primary-500 text-white flex-shrink-0">
            💡
          </div>
          <div>
            <p className="text-sm font-semibold text-primary-900 dark:text-primary-100 mb-1">
              New to OnLoan?
            </p>
            <p className="text-xs text-primary-700 dark:text-primary-300 mb-3">
              Start by claiming test USDT from the faucet, then deposit to start earning interest or borrow against your collateral.
            </p>
            <div className="flex gap-2">
              <Link to="/faucet">
                <Button variant="primary" size="sm">
                  Claim Test USDT
                </Button>
              </Link>
              <a
                href="https://docs.onloan.xyz"
                target="_blank"
                rel="noopener noreferrer"
              >
                <Button variant="ghost" size="sm">
                  Read Docs
                </Button>
              </a>
            </div>
          </div>
        </div>
      </div>
    </Card>
  );
};

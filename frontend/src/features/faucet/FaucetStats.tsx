import { TrendingUp, Users, Droplet } from 'lucide-react';
import { Card } from '../../components/ui';

export const FaucetStats = () => {
  // Mock data - in production, fetch from contract events or backend
  const stats = [
    {
      title: 'Total Claims',
      value: '1,247',
      icon: Users,
      color: 'text-blue-600 dark:text-blue-400',
      bg: 'bg-blue-100 dark:bg-blue-900/20',
    },
    {
      title: 'Total Distributed',
      value: '1,247,000 USDT',
      icon: TrendingUp,
      color: 'text-green-600 dark:text-green-400',
      bg: 'bg-green-100 dark:bg-green-900/20',
    },
    {
      title: 'Available in Faucet',
      value: '10,000,000 USDT',
      icon: Droplet,
      color: 'text-purple-600 dark:text-purple-400',
      bg: 'bg-purple-100 dark:bg-purple-900/20',
    },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      {stats.map((stat) => {
        const Icon = stat.icon;
        return (
          <Card key={stat.title} variant="standard" className="hover:shadow-md transition-shadow">
            <div className="flex items-center gap-4">
              <div className={`flex h-12 w-12 items-center justify-center rounded-xl ${stat.bg}`}>
                <Icon className={`h-6 w-6 ${stat.color}`} />
              </div>
              <div>
                <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">{stat.title}</p>
                <p className="text-xl font-bold text-gray-900 dark:text-gray-100">{stat.value}</p>
              </div>
            </div>
          </Card>
        );
      })}
    </div>
  );
};

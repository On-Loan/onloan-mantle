import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard,
  TrendingUp,
  HandCoins,
  FileText,
  Waves,
  Droplet,
  Receipt,
  User,
} from 'lucide-react';

const menuItems = [
  { icon: LayoutDashboard, label: 'Dashboard', path: '/dashboard' },
  { icon: TrendingUp, label: 'Lend', path: '/lend' },
  { icon: HandCoins, label: 'Borrow', path: '/borrow' },
  { icon: FileText, label: 'My Loans', path: '/my-loans' },
  { icon: Waves, label: 'Pool', path: '/pool' },
  { icon: Droplet, label: 'Faucet', path: '/faucet' },
  { icon: Receipt, label: 'Transactions', path: '/transactions' },
  { icon: User, label: 'Profile', path: '/profile' },
];

export const Sidebar = () => {
  const location = useLocation();

  return (
    <aside className="hidden lg:flex w-64 flex-col border-r border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 h-[calc(100vh-4rem)]">
      <nav className="flex-1 space-y-1 p-4">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.path;

          return (
            <Link
              key={item.path}
              to={item.path}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all ${
                isActive
                  ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400'
                  : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'
              }`}
            >
              <Icon className="h-5 w-5 flex-shrink-0" />
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>

      {/* Sidebar Footer */}
      <div className="p-4 border-t border-gray-200 dark:border-gray-800">
        <div className="rounded-xl bg-gradient-to-br from-primary-50 to-primary-100 dark:from-primary-900/20 dark:to-primary-800/20 p-4">
          <h3 className="text-sm font-semibold text-primary-900 dark:text-primary-100 mb-1">
            Need Help?
          </h3>
          <p className="text-xs text-primary-700 dark:text-primary-300 mb-3">
            Check our documentation
          </p>
          <a
            href="https://docs.onloan.xyz"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center text-xs font-medium text-primary-600 dark:text-primary-400 hover:underline"
          >
            View Docs →
          </a>
        </div>
      </div>
    </aside>
  );
};

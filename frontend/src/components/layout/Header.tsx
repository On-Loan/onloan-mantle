import { Link } from 'react-router-dom';
import { Menu, X } from 'lucide-react';
import { ConnectButton } from '../wallet/ConnectButton';
import { useState } from 'react';
import { Button } from '../ui';

export const Header = () => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 z-40 bg-white/95 dark:bg-gray-900/95 backdrop-blur-sm border-b border-gray-200 dark:border-gray-800">
      <div className="px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary-600 to-primary-700 text-white font-bold text-lg">
              OL
            </div>
            <span className="hidden sm:block text-xl font-bold text-gray-900 dark:text-gray-100">
              OnLoan
            </span>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center gap-1">
            <NavLink to="/dashboard">Dashboard</NavLink>
            <NavLink to="/lend">Lend</NavLink>
            <NavLink to="/borrow">Borrow</NavLink>
            <NavLink to="/my-loans">My Loans</NavLink>
            <NavLink to="/pool">Pool</NavLink>
            <NavLink to="/faucet">Faucet</NavLink>
          </nav>

          {/* Connect Button */}
          <div className="flex items-center gap-2">
            <ConnectButton />
            
            {/* Mobile Menu Button */}
            <Button
              variant="icon"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden"
            >
              {mobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </Button>
          </div>
        </div>

        {/* Mobile Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden py-4 border-t border-gray-200 dark:border-gray-800">
            <nav className="flex flex-col gap-2">
              <MobileNavLink to="/dashboard" onClick={() => setMobileMenuOpen(false)}>
                Dashboard
              </MobileNavLink>
              <MobileNavLink to="/lend" onClick={() => setMobileMenuOpen(false)}>
                Lend
              </MobileNavLink>
              <MobileNavLink to="/borrow" onClick={() => setMobileMenuOpen(false)}>
                Borrow
              </MobileNavLink>
              <MobileNavLink to="/my-loans" onClick={() => setMobileMenuOpen(false)}>
                My Loans
              </MobileNavLink>
              <MobileNavLink to="/pool" onClick={() => setMobileMenuOpen(false)}>
                Pool
              </MobileNavLink>
              <MobileNavLink to="/faucet" onClick={() => setMobileMenuOpen(false)}>
                Faucet
              </MobileNavLink>
              <MobileNavLink to="/transactions" onClick={() => setMobileMenuOpen(false)}>
                Transactions
              </MobileNavLink>
              <MobileNavLink to="/profile" onClick={() => setMobileMenuOpen(false)}>
                Profile
              </MobileNavLink>
            </nav>
          </div>
        )}
      </div>
    </header>
  );
};

const NavLink = ({ to, children }: { to: string; children: React.ReactNode }) => {
  return (
    <Link
      to={to}
      className="px-4 py-2 rounded-lg text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
    >
      {children}
    </Link>
  );
};

const MobileNavLink = ({
  to,
  onClick,
  children,
}: {
  to: string;
  onClick: () => void;
  children: React.ReactNode;
}) => {
  return (
    <Link
      to={to}
      onClick={onClick}
      className="px-4 py-3 rounded-lg text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
    >
      {children}
    </Link>
  );
};

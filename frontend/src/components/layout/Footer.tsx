import { Link } from 'react-router-dom';
import { Code2, MessageCircle, FileText } from 'lucide-react';

export const Footer = () => {
  return (
    <footer className="border-t border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 pb-20 lg:pb-0">
      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary-600 to-primary-700 text-white font-bold text-lg">
                OL
              </div>
              <span className="text-xl font-bold text-gray-900 dark:text-gray-100">
                OnLoan
              </span>
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Decentralized P2P lending on Mantle Chain. Transparent, secure, and efficient.
            </p>
          </div>

          {/* Product */}
          <div>
            <h3 className="text-sm font-semibold text-gray-900 dark:text-gray-100 mb-4">
              Product
            </h3>
            <ul className="space-y-2">
              <FooterLink to="/lend">Lend</FooterLink>
              <FooterLink to="/borrow">Borrow</FooterLink>
              <FooterLink to="/pool">Pool Stats</FooterLink>
              <FooterLink to="/faucet">Testnet Faucet</FooterLink>
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h3 className="text-sm font-semibold text-gray-900 dark:text-gray-100 mb-4">
              Resources
            </h3>
            <ul className="space-y-2">
              <FooterLink to="/docs" external>
                Documentation
              </FooterLink>
              <FooterLink to="https://github.com/onloan" external>
                GitHub
              </FooterLink>
              <FooterLink to="/components">
                Component Library
              </FooterLink>
              <FooterLink to="https://sepolia.mantlescan.xyz" external>
                Block Explorer
              </FooterLink>
            </ul>
          </div>

          {/* Community */}
          <div>
            <h3 className="text-sm font-semibold text-gray-900 dark:text-gray-100 mb-4">
              Community
            </h3>
            <div className="flex gap-3">
              <SocialLink href="https://github.com/onloan" aria-label="GitHub">
                <Code2 className="h-5 w-5" />
              </SocialLink>
              <SocialLink href="https://discord.gg/onloan" aria-label="Discord">
                <MessageCircle className="h-5 w-5" />
              </SocialLink>
              <SocialLink href="https://docs.onloan.xyz" aria-label="Documentation">
                <FileText className="h-5 w-5" />
              </SocialLink>
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400 mt-4">
              Built on Mantle Sepolia Testnet
            </p>
          </div>
        </div>

        {/* Bottom */}
        <div className="mt-12 pt-8 border-t border-gray-200 dark:border-gray-800">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-sm text-gray-600 dark:text-gray-400">
              © {new Date().getFullYear()} OnLoan Protocol. All rights reserved.
            </p>
            <div className="flex gap-6">
              <Link
                to="/terms"
                className="text-sm text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400"
              >
                Terms
              </Link>
              <Link
                to="/privacy"
                className="text-sm text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400"
              >
                Privacy
              </Link>
              <Link
                to="/security"
                className="text-sm text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400"
              >
                Security
              </Link>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
};

const FooterLink = ({
  to,
  external = false,
  children,
}: {
  to: string;
  external?: boolean;
  children: React.ReactNode;
}) => {
  if (external) {
    return (
      <li>
        <a
          href={to}
          target="_blank"
          rel="noopener noreferrer"
          className="text-sm text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
        >
          {children}
        </a>
      </li>
    );
  }

  return (
    <li>
      <Link
        to={to}
        className="text-sm text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
      >
        {children}
      </Link>
    </li>
  );
};

const SocialLink = ({
  href,
  children,
  ...props
}: {
  href: string;
  children: React.ReactNode;
  [key: string]: unknown;
}) => {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className="flex h-10 w-10 items-center justify-center rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400 hover:bg-primary-100 dark:hover:bg-primary-900/20 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
      {...props}
    >
      {children}
    </a>
  );
};

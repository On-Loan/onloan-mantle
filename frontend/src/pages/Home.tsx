import { Link } from 'react-router-dom';
import { useAccount } from 'wagmi';
import { TrendingUp, Shield, Zap, ArrowRight, CheckCircle, Sparkles } from 'lucide-react';
import { Button } from '../components/ui';
import { ConnectButton } from '../components/wallet/ConnectButton';

export const Home = () => {
  const { isConnected } = useAccount();

  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50 dark:from-gray-950 dark:to-gray-900">
      {/* Navigation Header */}
      <header className="sticky top-0 z-40 bg-white/95 dark:bg-gray-900/95 backdrop-blur-sm border-b border-gray-200 dark:border-gray-800">
        <div className="px-6 lg:px-8 max-w-7xl mx-auto">
          <div className="flex h-16 items-center justify-between">
            <Link to="/" className="flex items-center gap-2">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary-600 to-primary-700 text-white font-bold text-lg">
                OL
              </div>
              <span className="text-xl font-bold text-gray-900 dark:text-gray-100">
                OnLoan
              </span>
            </Link>

            <nav className="hidden md:flex items-center gap-6">
              <Link to="/dashboard" className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors">
                Dashboard
              </Link>
              <Link to="/lend" className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors">
                Lend
              </Link>
              <Link to="/borrow" className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors">
                Borrow
              </Link>
              <Link to="/pool" className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors">
                Pool
              </Link>
              <ConnectButton />
            </nav>

            <div className="md:hidden">
              <ConnectButton />
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative overflow-hidden">
        <div className="px-6 py-20 lg:px-8 lg:py-32 xl:py-40 max-w-7xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            {/* Left Column - Content */}
            <div className="space-y-8">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary-100 dark:bg-primary-900/20 border border-primary-200 dark:border-primary-800">
                <Sparkles className="h-4 w-4 text-primary-600 dark:text-primary-400" />
                <span className="text-sm font-semibold text-primary-900 dark:text-primary-100">
                  Built on Mantle Chain
                </span>
              </div>

              <h1 className="text-5xl lg:text-6xl xl:text-7xl font-bold text-gray-900 dark:text-gray-100 leading-tight">
                Decentralized P2P Lending
                <span className="block text-primary-600 dark:text-primary-400 mt-2">
                  Made Simple
                </span>
              </h1>

              <p className="text-xl lg:text-2xl text-gray-600 dark:text-gray-400 leading-relaxed">
                Lend your USDT to earn competitive APY or borrow against crypto collateral. 
                Instant matching, transparent rates, and automated security.
              </p>

              <div className="flex flex-col sm:flex-row gap-4">
                {isConnected ? (
                  <Link to="/dashboard">
                    <Button variant="primary" size="lg" className="w-full sm:w-auto text-lg px-8">
                      Go to Dashboard
                      <ArrowRight className="ml-2 h-5 w-5" />
                    </Button>
                  </Link>
                ) : (
                  <div className="flex items-center gap-4">
                    <ConnectButton />
                    <Link to="/faucet">
                      <Button variant="secondary" size="lg" className="w-full sm:w-auto">
                        Get Test USDT
                      </Button>
                    </Link>
                  </div>
                )}
              </div>

              {/* Stats */}
              <div className="grid grid-cols-3 gap-6 pt-8 border-t border-gray-200 dark:border-gray-800">
                <div>
                  <p className="text-3xl font-bold text-gray-900 dark:text-gray-100">8.5%</p>
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">Current APY</p>
                </div>
                <div>
                  <p className="text-3xl font-bold text-gray-900 dark:text-gray-100">$2.5M</p>
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">Total Locked</p>
                </div>
                <div>
                  <p className="text-3xl font-bold text-gray-900 dark:text-gray-100">1,247</p>
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">Active Loans</p>
                </div>
              </div>
            </div>

            {/* Right Column - Visual */}
            <div className="relative lg:pl-8">
              <div className="relative rounded-3xl bg-gradient-to-br from-primary-600 to-primary-800 p-8 shadow-2xl">
                <div className="space-y-4">
                  <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 border border-white/20">
                    <div className="flex items-center justify-between mb-4">
                      <span className="text-white/80 text-sm">Your Deposits</span>
                      <TrendingUp className="h-5 w-5 text-green-400" />
                    </div>
                    <p className="text-4xl font-bold text-white">$15,420</p>
                    <p className="text-green-400 text-sm mt-2">+12.5% this month</p>
                  </div>

                  <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 border border-white/20">
                    <div className="flex items-center justify-between mb-4">
                      <span className="text-white/80 text-sm">Interest Earned</span>
                      <Sparkles className="h-5 w-5 text-yellow-400" />
                    </div>
                    <p className="text-4xl font-bold text-white">$892</p>
                    <p className="text-yellow-400 text-sm mt-2">8.5% APY</p>
                  </div>

                  <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 border border-white/20">
                    <div className="flex items-center justify-between mb-4">
                      <span className="text-white/80 text-sm">Credit Score</span>
                      <Shield className="h-5 w-5 text-blue-400" />
                    </div>
                    <p className="text-4xl font-bold text-white">850</p>
                    <p className="text-blue-400 text-sm mt-2">Excellent Tier</p>
                  </div>
                </div>

                {/* Glow effect */}
                <div className="absolute -inset-4 bg-primary-500 opacity-20 blur-3xl -z-10" />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 lg:py-32 px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-gray-100 mb-4">
              Why Choose OnLoan?
            </h2>
            <p className="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
              Experience the future of decentralized lending with transparent rates, 
              instant matching, and robust security.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {/* Feature 1 */}
            <div className="bg-white dark:bg-gray-900 rounded-2xl p-8 border border-gray-200 dark:border-gray-800 hover:border-primary-300 dark:hover:border-primary-700 transition-colors">
              <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-green-100 dark:bg-green-900/20 mb-6">
                <TrendingUp className="h-7 w-7 text-green-600 dark:text-green-400" />
              </div>
              <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-3">
                Earn Competitive APY
              </h3>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Deposit USDT and earn up to 10% APY. Interest accrues continuously 
                and you can withdraw anytime.
              </p>
            </div>

            {/* Feature 2 */}
            <div className="bg-white dark:bg-gray-900 rounded-2xl p-8 border border-gray-200 dark:border-gray-800 hover:border-primary-300 dark:hover:border-primary-700 transition-colors">
              <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-blue-100 dark:bg-blue-900/20 mb-6">
                <Shield className="h-7 w-7 text-blue-600 dark:text-blue-400" />
              </div>
              <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-3">
                Secure & Transparent
              </h3>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Smart contracts ensure fair liquidation. Chainlink oracles provide 
                accurate pricing. Full on-chain transparency.
              </p>
            </div>

            {/* Feature 3 */}
            <div className="bg-white dark:bg-gray-900 rounded-2xl p-8 border border-gray-200 dark:border-gray-800 hover:border-primary-300 dark:hover:border-primary-700 transition-colors">
              <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-purple-100 dark:bg-purple-900/20 mb-6">
                <Zap className="h-7 w-7 text-purple-600 dark:text-purple-400" />
              </div>
              <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-3">
                Instant & Low-Cost
              </h3>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Built on Mantle Chain for lightning-fast transactions at minimal cost. 
                No waiting, no high gas fees.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20 lg:py-32 px-6 lg:px-8 bg-gray-50 dark:bg-gray-900/50">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-gray-100 mb-4">
              Get Started in Minutes
            </h2>
            <p className="text-xl text-gray-600 dark:text-gray-400">
              Simple steps to start lending or borrowing
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
            {/* Lenders */}
            <div className="space-y-6">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-green-100 dark:bg-green-900/20">
                <span className="text-sm font-semibold text-green-900 dark:text-green-100">
                  For Lenders
                </span>
              </div>

              <div className="space-y-4">
                {[
                  { step: 1, title: 'Connect Wallet', desc: 'Use MetaMask or any Web3 wallet' },
                  { step: 2, title: 'Deposit USDT', desc: 'Choose amount and approve transaction' },
                  { step: 3, title: 'Earn Interest', desc: 'Watch your balance grow automatically' },
                  { step: 4, title: 'Withdraw Anytime', desc: 'Access your funds instantly' },
                ].map((item) => (
                  <div key={item.step} className="flex gap-4">
                    <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400 font-bold flex-shrink-0">
                      {item.step}
                    </div>
                    <div>
                      <h4 className="font-semibold text-gray-900 dark:text-gray-100 mb-1">
                        {item.title}
                      </h4>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        {item.desc}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Borrowers */}
            <div className="space-y-6">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-blue-100 dark:bg-blue-900/20">
                <span className="text-sm font-semibold text-blue-900 dark:text-blue-100">
                  For Borrowers
                </span>
              </div>

              <div className="space-y-4">
                {[
                  { step: 1, title: 'Connect Wallet', desc: 'Use MetaMask or any Web3 wallet' },
                  { step: 2, title: 'Select Loan Type', desc: 'Personal, Home, Business, or Auto' },
                  { step: 3, title: 'Provide Collateral', desc: 'Lock ETH or USDT as collateral' },
                  { step: 4, title: 'Receive USDT', desc: 'Get instant liquidity in your wallet' },
                ].map((item) => (
                  <div key={item.step} className="flex gap-4">
                    <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400 font-bold flex-shrink-0">
                      {item.step}
                    </div>
                    <div>
                      <h4 className="font-semibold text-gray-900 dark:text-gray-100 mb-1">
                        {item.title}
                      </h4>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        {item.desc}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 lg:py-32 px-6 lg:px-8">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-gray-100 mb-6">
            Ready to Get Started?
          </h2>
          <p className="text-xl text-gray-600 dark:text-gray-400 mb-8">
            Join thousands of users lending and borrowing on OnLoan
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            {isConnected ? (
              <>
                <Link to="/lend">
                  <Button variant="primary" size="lg" className="w-full sm:w-auto text-lg px-8">
                    Start Lending
                    <TrendingUp className="ml-2 h-5 w-5" />
                  </Button>
                </Link>
                <Link to="/borrow">
                  <Button variant="secondary" size="lg" className="w-full sm:w-auto text-lg px-8">
                    Borrow Now
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </Button>
                </Link>
              </>
            ) : (
              <ConnectButton />
            )}
          </div>

          <div className="mt-12 flex items-center justify-center gap-8 text-sm text-gray-600 dark:text-gray-400">
            <div className="flex items-center gap-2">
              <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
              <span>Audited Contracts</span>
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
              <span>Low Gas Fees</span>
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
              <span>24/7 Access</span>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

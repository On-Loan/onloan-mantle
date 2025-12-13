import type { ReactNode } from 'react';
import { Header } from './Header';
import { Sidebar } from './Sidebar';
import { BottomNav } from './BottomNav';
import { Footer } from './Footer';

interface MainLayoutProps {
  children: ReactNode;
}

export const MainLayout = ({ children }: MainLayoutProps) => {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-950">
      <Header />
      
      <div className="flex">
        <Sidebar />
        
        <main className="flex-1 w-full min-h-[calc(100vh-4rem)]">
          <div className="px-6 py-8 lg:px-8">
            {children}
          </div>
          <Footer />
        </main>
      </div>

      <BottomNav />
    </div>
  );
};

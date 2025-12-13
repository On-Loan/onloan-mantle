import { Routes, Route } from 'react-router-dom';
import { MainLayout } from './components/layout/MainLayout';
import { Home } from './pages/Home';
import { Dashboard } from './pages/Dashboard';
import { Lend } from './pages/Lend';
import { Borrow } from './pages/Borrow';
import { MyLoans } from './pages/MyLoans';
import { Pool } from './pages/Pool';
import { Faucet } from './pages/Faucet';
import { Transactions } from './pages/Transactions';
import { Profile } from './pages/Profile';
import { ComponentTest } from './pages/ComponentTest';
import './App.css';

function App() {
  return (
    <Routes>
      {/* Landing page without layout */}
      <Route path="/" element={<Home />} />
      
      {/* Main app routes with layout */}
      <Route
        path="/dashboard"
        element={
          <MainLayout>
            <Dashboard />
          </MainLayout>
        }
      />
      <Route
        path="/lend"
        element={
          <MainLayout>
            <Lend />
          </MainLayout>
        }
      />
      <Route
        path="/borrow"
        element={
          <MainLayout>
            <Borrow />
          </MainLayout>
        }
      />
      <Route
        path="/my-loans"
        element={
          <MainLayout>
            <MyLoans />
          </MainLayout>
        }
      />
      <Route
        path="/pool"
        element={
          <MainLayout>
            <Pool />
          </MainLayout>
        }
      />
      <Route
        path="/faucet"
        element={
          <MainLayout>
            <Faucet />
          </MainLayout>
        }
      />
      <Route
        path="/transactions"
        element={
          <MainLayout>
            <Transactions />
          </MainLayout>
        }
      />
      <Route
        path="/profile"
        element={
          <MainLayout>
            <Profile />
          </MainLayout>
        }
      />
      
      {/* Component test page without layout */}
      <Route path="/components" element={<ComponentTest />} />
    </Routes>
  );
}

export default App;

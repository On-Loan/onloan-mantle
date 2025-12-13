import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { mantleSepolia } from './chains';

export const config = getDefaultConfig({
  appName: 'OnLoan',
  projectId: import.meta.env.VITE_WALLETCONNECT_PROJECT_ID || 'YOUR_PROJECT_ID',
  chains: [mantleSepolia],
  ssr: false,
});

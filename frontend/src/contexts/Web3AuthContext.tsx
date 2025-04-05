import React, { createContext, useContext, useState, useEffect } from 'react';
import { useWeb3React } from '@web3-react/core';
import { InjectedConnector } from '@web3-react/injected-connector';

interface Web3AuthContextType {
  connect: () => Promise<void>;
  disconnect: () => void;
  isConnected: boolean;
  account: string | null;
  chainId: number | null;
}

const Web3AuthContext = createContext<Web3AuthContextType>({
  connect: async () => {},
  disconnect: () => {},
  isConnected: false,
  account: null,
  chainId: null,
});

export const injected = new InjectedConnector({
  supportedChainIds: [1, 3, 4, 5, 42, 1337], // Mainnet, Ropsten, Rinkeby, Goerli, Kovan, Local
});

export const Web3AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { activate, deactivate, account, chainId, active } = useWeb3React();
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    const checkConnection = async () => {
      const isAuthorized = await injected.isAuthorized();
      if (isAuthorized) {
        try {
          await activate(injected);
          setIsConnected(true);
        } catch (error) {
          console.error('Failed to connect:', error);
        }
      }
    };

    checkConnection();
  }, [activate]);

  const connect = async () => {
    try {
      await activate(injected);
      setIsConnected(true);
    } catch (error) {
      console.error('Failed to connect:', error);
    }
  };

  const disconnect = () => {
    try {
      deactivate();
      setIsConnected(false);
    } catch (error) {
      console.error('Failed to disconnect:', error);
    }
  };

  return (
    <Web3AuthContext.Provider
      value={{
        connect,
        disconnect,
        isConnected: active || isConnected,
        account: account || null,
        chainId: chainId || null,
      }}
    >
      {children}
    </Web3AuthContext.Provider>
  );
};

export const useWeb3Auth = () => useContext(Web3AuthContext); 
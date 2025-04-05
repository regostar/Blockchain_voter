import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import { Provider } from 'react-redux';
import { Web3ReactProvider } from '@web3-react/core';
import { ethers } from 'ethers';
import { store } from './store';
import theme from './theme';
import Layout from './components/Layout';
import Home from './pages/Home';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Election from './pages/Election';
import Admin from './pages/Admin';
import { Web3AuthProvider } from './contexts/Web3AuthContext';

function getLibrary(provider: any) {
  return new ethers.providers.Web3Provider(provider);
}

function App() {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <Web3AuthProvider>
        <Provider store={store}>
          <ThemeProvider theme={theme}>
            <CssBaseline />
            <Router>
              <Layout>
                <Routes>
                  <Route path="/" element={<Home />} />
                  <Route path="/login" element={<Login />} />
                  <Route path="/dashboard" element={<Dashboard />} />
                  <Route path="/election/:id" element={<Election />} />
                  <Route path="/admin" element={<Admin />} />
                </Routes>
              </Layout>
            </Router>
          </ThemeProvider>
        </Provider>
      </Web3AuthProvider>
    </Web3ReactProvider>
  );
}

export default App; 
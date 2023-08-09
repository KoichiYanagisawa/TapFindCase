/** @jsxImportSource @emotion/react */
import { Global, css } from '@emotion/react';
import reset from './styles/reset.css';
import { Provider, useDispatch } from 'react-redux';
import store from './store';
import React, { useEffect, Suspense, useState } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import { PageTitleProvider } from './contexts/PageTitle';
import ModelSelectPage from './pages/ModelSelectPage';
import CaseDetailPage from './pages/CaseDetailPage';
import FlexibleListPage from './pages/FlexibleListPage';
import Header from './components/Header';
import Footer from './components/Footer';
import Modal from './components/Modal';
import { termsContent, privacyContent } from './components/Terms';
import './styles/three-dots.min.css';
import CookieConsent from './components/CookieConsent';
import axios from 'axios';
import Cookies from 'js-cookie';

const loadingStyles = css`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #000;
`;

function App() {
  const dispatch = useDispatch();
  const [isTermsModalOpen, setTermsModalOpen] = useState(false);
  const [isPrivacyModalOpen, setPrivacyModalOpen] = useState(false);

  const handleTermsClick = () => {
    setTermsModalOpen(true);
  };

  const handlePrivacyClick = () => {
    setPrivacyModalOpen(true);
  };

  const handleCloseModal = () => {
    setPrivacyModalOpen(false);
    setTermsModalOpen(false);
  };

  useEffect(() => {
    const hasGivenConsent = Cookies.get('hasGivenConsent');
    if (hasGivenConsent === 'true') {
      const userId = Cookies.get('userId');
      if (userId) {
        dispatch({ type: 'SET_USER_INFO_LOADING', payload: true });
        axios.get(`${process.env.REACT_APP_API_URL}/api/users/${userId}`)
          .then((response) => {
            dispatch({ type: 'SET_USER_INFO', payload: response.data });
          })
          .catch((error) => {
            console.error(`Failed to fetch user info: ${error}`);
          })
          .finally(() => {
            dispatch({ type: 'SET_USER_INFO_LOADING', payload: false });
          });
      }
    }
  }, [dispatch]);

  return (
    <PageTitleProvider>
      <Router>
        <Header onTermsClick={handleTermsClick} onPrivacyClick={handlePrivacyClick} />
        <Suspense fallback={<div css={loadingStyles}><div className="dot-spin"></div></div>}>
          <Routes>
            <Route path="/" element={<ModelSelectPage />} />
            <Route path="/product/:model" element={<FlexibleListPage />} />
            <Route path="/favorite" element={<FlexibleListPage />} />
            <Route path="/history" element={<FlexibleListPage />} />
            <Route path="/product/detail/:caseName" element={<CaseDetailPage />} />
          </Routes>
        </Suspense>
        {isTermsModalOpen && <Modal content={termsContent} onClose={handleCloseModal} />}
        {isPrivacyModalOpen && <Modal content={privacyContent} onClose={handleCloseModal} />}
        <Footer />
        <CookieConsent onPrivacyClick={handlePrivacyClick} />
      </Router>
    </PageTitleProvider>
  );
}

function AppWithStore() {
  return (
    <Provider store={store}>
      <Global styles={reset} />
      <App />
    </Provider>
  );
}

export default AppWithStore;

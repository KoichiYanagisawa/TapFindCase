/** @jsxImportSource @emotion/react */
import { Global,css } from '@emotion/react';
import { Provider, useDispatch } from 'react-redux';
import store from './store';
import axios from 'axios';
import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import {v4 as uuidv4} from 'uuid';
import Cookies from 'js-cookie';
import { PageTitleProvider } from './contexts/PageTitle';
import ModelSelectPage from './pages/ModelSelectPage';
import CaseDetailPage from './pages/CaseDetailPage';
import reset from './styles/reset.css';
import FlexibleListPage from './pages/FlexibleListPage';
import './styles/three-dots.min.css';

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
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const dispatch = useDispatch();

  useEffect(() => {
    let userId = Cookies.get('userId');

    if (!userId) {
      userId = uuidv4();
      Cookies.set('userId', userId);
    }

    axios.get(`${process.env.REACT_APP_API_URL}/api/users/${userId}`)
      .then((response) => {
        dispatch({
          type: 'SET_USER_INFO',
          payload: response.data
        });
      })
      .catch((error) => {
        setError(`Failed to fetch user info: ${error}`);
      })
      .finally(() => {
        setLoading(false);
      });
  }, [dispatch]);

  if (loading) return <div css={loadingStyles}>
                        <div className="dot-spin"></div>
                      </div>;
  if (error) return <div>エラー：管理者に問い合わせてください。</div>;

  return (
    <PageTitleProvider>
      <Router>
        <Routes>
          <Route path="/" element={<ModelSelectPage />} />
          <Route path="/product/:model" element={<FlexibleListPage />} />
          <Route path="/favorite" element={<FlexibleListPage />} />
          <Route path="/history" element={<FlexibleListPage />} />
          <Route path="/product/detail/:caseName" element={<CaseDetailPage />} />
        </Routes>
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

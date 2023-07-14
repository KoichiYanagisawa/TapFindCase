import { Provider, useDispatch } from 'react-redux';
import store from './store';
import axios from 'axios';
import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import {v4 as uuidv4} from 'uuid';
import Cookies from 'js-cookie';
import ModelSelectPage from './pages/ModelSelectPage';
import CaseListPage from './pages/CaseListPage';
import CaseDetailPage from './pages/CaseDetailPage';
import { Global } from '@emotion/react';
import reset from './styles/reset.css';


function App() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const dispatch = useDispatch();

  useEffect(() => {
    let userId = Cookies.get('userId');

    // Cookieがなければuuidを生成してCookieに保存する
    if (!userId) {
      userId = uuidv4();
      Cookies.set('userId', userId);
    }

    // ユーザーIDをRails APIに送信してユーザー情報を取得する
    axios.get(`http://localhost:3000/api/users/${userId}`)
      .then((response) => {
        // ユーザー情報をReduxのStoreに保存する
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

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;


  return (
    <>
        <Router>
          <Routes>
            <Route path="/" element={<ModelSelectPage />} />
            <Route path="/product/:model" element={<CaseListPage />} />
            <Route path="/product/detail/:id" element={<CaseDetailPage />} />
          </Routes>
        </Router>
    </>
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

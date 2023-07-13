import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import ModelSelectPage from './pages/ModelSelectPage';
import CaseListPage from './pages/CaseListPage';
import CaseDetailPage from './pages/CaseDetailPage';
import { Global } from '@emotion/react';
import reset from './styles/reset.css';

function App() {
  return (
    <>
      <Global styles={reset} />
      <Router>
        <Routes>
          <Route path="/" element={<ModelSelectPage />} />
          <Route path="/cases/:model" element={<CaseListPage />} />
          <Route path="/product/detail/:id" element={<CaseDetailPage />} />
        </Routes>
      </Router>
    </>
  );
}

export default App;

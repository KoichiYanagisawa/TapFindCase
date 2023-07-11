import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import ModelSelectPage from './pages/ModelSelectPage';
import CaseListPage from './pages/CaseListPage';
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
        </Routes>
      </Router>
    </>
  );
}

export default App;

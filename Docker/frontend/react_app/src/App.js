import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import ModelSelectPage from './ModelSelectPage';
import CaseListPage from './CaseListPage';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<ModelSelectPage />} />
        <Route path="/cases/:model" element={<CaseListPage />} />
      </Routes>
    </Router>
  );
}

export default App;

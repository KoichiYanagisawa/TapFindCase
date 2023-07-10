/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import 'tailwindcss/tailwind.css';
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { solid } from '@fortawesome/fontawesome-svg-core/import.macro'

const containerStyles = css`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100vh;
  padding: 20px;
  box-sizing: border-box;
`;

const selectStyles = css`
  width: 100%;
  height: 40px;
  margin-bottom: 20px;
  border-radius: 8px;
  font-size: 1.25rem;
`;

const buttonStyles = css`
  width: 100%;
  height: 40px;
  background-color: #007BFF;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.25rem;
`;

function Header() {
  return (
    <div>
      <h1>TapFindCase</h1>
    </div>
  );
}

function ModelSelectPage() {
  const [products, setProducts] = useState([]);
  const [selectedModelName, setSelectedModelName] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetch('http://localhost:3000')
      .then(response => response.json())
      .then(data => setProducts(data));
  }, []);

  const handleModelChange = (event) => {
    setSelectedModelName(event.target.value);
  };

  const handleSearchClick = () => {
    if (selectedModelName !== '') {
      navigate(`/cases/${selectedModelName}`);
    }
  };

  return (
    <>
      <Header />
      <div css={containerStyles}>
      <select css={selectStyles} value={selectedModelName} onChange={handleModelChange}>
        <option value="">ケースを選択してください<FontAwesomeIcon icon={solid("chevron-down")} /></option>
        {products.map((product, index) => (
          <option key={index} value={product.model}>{product.model}</option>
        ))}
      </select>
      <button css={buttonStyles} onClick={handleSearchClick} disabled={!selectedModelName}>ケースを探す</button>
    </div>
    </>
  );
}

export default ModelSelectPage;

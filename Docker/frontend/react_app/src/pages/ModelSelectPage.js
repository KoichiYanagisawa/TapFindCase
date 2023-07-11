/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import 'tailwindcss/tailwind.css'; // これまだ使ってない！！！
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from '../components/Header'; // Headerコンポーネントをインポート
import Dropdown from '../components/Dropdown'; // Dropdownコンポーネントをインポート
import SearchButton from '../components/SearchButton'; // SearchButtonコンポーネントをインポート
import Footer from '../components/Footer'; // Footerコンポーネントをインポート

const containerStyles = css`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100vh;
  padding: 20px;
  box-sizing: border-box;
  background: linear-gradient(rgba(255, 255, 255, 0.2), rgba(255, 255, 255, 0.2)), url('./ts038A4472_TP_V.jpg') no-repeat center center fixed;
  background-size: cover;
  font-family: 'Montserrat', sans-serif;
`;

function ModelSelectPage() {
  const [products, setProducts] = useState([]);
  const [selectedModelName, setSelectedModelName] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetch('http://localhost:3000')
      .then(response => response.json())
      .then(data => setProducts(data));
  }, []);

  const handleModelChange = (value) => {
    setSelectedModelName(value);
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
      <Dropdown
        options={products.map(product => ({ value: product.model, label: product.model }))}
        value={selectedModelName}
        onChange={handleModelChange}
        placeholder="機種を選択してください"
      />
      <SearchButton onClick={handleSearchClick} disabled={!selectedModelName} />
    </div>
    <Footer />
    </>
  );
}

export default ModelSelectPage;

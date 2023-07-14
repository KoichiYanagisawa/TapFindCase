/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from '../components/Header';
import Dropdown from '../components/Dropdown';
import CustomButton from '../components/CustomButton';
import Footer from '../components/Footer';
import { IoSearchCircleSharp } from 'react-icons/io5';

const containerStyles = css`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: calc(100vh - 20px);
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
      navigate(`/product/${selectedModelName}`);
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
        <CustomButton onClick={handleSearchClick}
                      disabled={!selectedModelName}
                      text="ケースを探す"
                      Icon={IoSearchCircleSharp}
        />
    </div>
    <Footer />
    </>
  );
}

export default ModelSelectPage;

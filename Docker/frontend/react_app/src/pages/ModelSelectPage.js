/** @jsxImportSource @emotion/react */
import { css, keyframes } from '@emotion/react';
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { usePageTitle } from '../contexts/PageTitle';
import Dropdown from '../components/Dropdown';
import CustomButton from '../components/CustomButton';
import { IoSearchCircleSharp } from 'react-icons/io5';
import { PiArrowFatLinesDownFill } from 'react-icons/pi';


const bounce1 = keyframes`
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-15px);
  }
  60% {
    transform: translateY(-10px);
  }
`;

const bounce2 = keyframes`
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-12px);
  }
  60% {
    transform: translateY(-8px);
  }
`;

const bounce3 = keyframes`
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-9px);
  }
  60% {
    transform: translateY(-5px);
  }
`;

const containerStyles = css`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: calc(100vh - 20px);
  padding: 20px;
  box-sizing: border-box;
  background: linear-gradient(rgba(255, 255, 255, 0.7), rgba(255, 255, 255, 0.3)), url('/alina-chernysheva-jFfNeWDikOY-unsplash.jpg') no-repeat center center fixed;
  background-size: cover;
  font-family: 'Montserrat', sans-serif;
`;

const sloganStyles = css`
  font-weight: 900;
  position: absolute;
  top: 20%;
  width: 100%;
  color: #000000;
  text-align: center;
`;

const sloganLineStyles1 = css`
  padding: 0.5rem 0;
  -webkit-text-stroke: 0.3px white;
  font-size: 2.5rem;
  animation: ${bounce1} 2s infinite ease-out;

  @media (max-width: 640px) {
    font-size: 2.0rem;
  }
  @media (max-width: 550px) {
    font-size: 1.5rem;
  }
  @media (max-width: 400px) {
    font-size: 1.2rem;
  }
`;

const sloganLineStyles2 = css`
  padding: 0.5rem 0;
  -webkit-text-stroke: 0.3px white;
  font-size: 2.5rem;
  animation: ${bounce2} 2s infinite ease-out;

  @media (max-width: 640px) {
    font-size: 2.0rem;
  }
  @media (max-width: 550px) {
    font-size: 1.5rem;
  }
  @media (max-width: 400px) {
    font-size: 1.2rem;
  }
`;
const sloganLineStyles3 = css`
  padding: 0.5rem 0;
  -webkit-text-stroke: 0.3px white;
  font-size: 2.5rem;
  animation: ${bounce3} 2s infinite ease-out;

  @media (max-width: 640px) {
    font-size: 2.0rem;
  }
  @media (max-width: 550px) {
    font-size: 1.5rem;
  }
  @media (max-width: 400px) {
    font-size: 1.2rem;
  }
`;


function ModelSelectPage() {
  const [products, setProducts] = useState([]);
  const [selectedModelName, setSelectedModelName] = useState('');
  const navigate = useNavigate();
  const { setPageTitle } = usePageTitle();
  useEffect(() => {
    setPageTitle('ーTOP');
  }, [setPageTitle]);

  useEffect(() => {
    fetch(`${process.env.REACT_APP_API_URL}/products`)
      .then(response => response.json())
      .then(data => setProducts(data))
      .catch((error) => {
        console.error('Failed to fetch data:', error);
      });
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
      <div css={containerStyles}>
        <div css={sloganStyles}>
          <div css={sloganLineStyles1}>画面をタップするだけ！</div>
          <div css={sloganLineStyles2}>お気に入りのケースを見つけよう！</div>
          <div css={sloganLineStyles3}><PiArrowFatLinesDownFill/></div>
        </div>
        <Dropdown
          options={products.map(product => ({ value: product.model, label: product.model }))}
          value={selectedModelName}
          onChange={handleModelChange}
          placeholder="機種を選択してください"
        />
        <CustomButton onClick={handleSearchClick}
                      disabled={!selectedModelName}
                      text={selectedModelName ? "ケースを探しに行く" : "機種選択待機中"}
                      style={css`
                        background-color: ${selectedModelName ? '#000' : '#262626'};
                      `}
                      Icon={IoSearchCircleSharp}
        />
      </div>
    </>
  );
}

export default ModelSelectPage;

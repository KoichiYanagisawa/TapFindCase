/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { Carousel } from 'react-responsive-carousel';
import { useSelector } from 'react-redux';
import 'react-responsive-carousel/lib/styles/carousel.min.css';
import '../styles/three-dots.min.css';

import { usePageTitle } from '../contexts/PageTitle';
import CustomButton from '../components/CustomButton';
import { MdFavorite } from 'react-icons/md';
import { BsShop } from 'react-icons/bs';

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

const containerStyles = css`
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  box-sizing: border-box;
  font-family: 'Montserrat', sans-serif;
  max-width: 1200px;
  margin: 0 auto;
  padding-top: 80px;
  margin-bottom: 20px;
  background-color: #fff;
  color: #000;

  @media (min-width: 768px) {
    flex-direction: row;
    justify-content: space-between;
  }
`;

const thumbnailStyles = css`
  border: 1px solid black;
  cursor: pointer;
`;

const thumbnailContainerStyles = css`
  flex: 2;
  order: 2;

  @media (min-width: 768px) {
    order: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
`;


const imageStyles = css`
  width: 100%;
  height: auto;
  border-radius: 8px;
`;

const imageContainerStyles = css`
  flex: 6;
  order: 1;
  position: relative;

  @media (min-width: 768px) {
    order: 2;
  }
`;

const detailContainerStyles = css`
  flex: 4;
  order: 3;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  @media (min-width: 768px) {
    order: 3;
  }
`;

const productPrice = css`
  color: #ff0000;
  font-size: 1.5rem;
  font-weight: bold;
`;

const productNameStyles = css`
  font-size: 2.5rem;
  font-weight: bold;
  @media (max-width: 1024px) {
    font-size: 2rem;
  }
  @media (max-width: 640px) {
    font-size: 1.5rem;
  }
  @media (max-width: 320px) {
    font-size: 1rem;
`;

const productDetailStyles = css`
  font-size: 1.5rem;
  @media (max-width: 1024px) {
    font-size: 1.2rem;
  }
  @media (max-width: 640px) {
    font-size: 1rem;
  }
  @media (max-width: 320px) {
    font-size: 0.8rem;
  }
`;

const hideOnDesktop = css`
  @media (min-width: 768px) {
    display: none;
  }
`;


function ProductDetailPage() {
  const userInfo = useSelector((state) => state.userInfo);
  const [product, setProduct] = useState(null);
  const [imageCount, setImageCount] = useState(0);
  const [displayImage, setDisplayImage] = useState(null);
  const { caseName } = useParams();
  const [isFavorited, setIsFavorited] = useState(false);
  const { setPageTitle } = usePageTitle();
  useEffect(() => {
    setPageTitle('ー商品詳細');
  }, [setPageTitle]);



  useEffect(() => {
    fetch(`${process.env.REACT_APP_API_URL}/products/detail/${encodeURIComponent(caseName)}`)
      .then(response => response.json())
      .then(data => {
        setProduct(data.product);
        setDisplayImage(data.product.image_urls[0]);
        setImageCount(data.product.thumbnail_urls.length);
      });

    if (userInfo && userInfo.id){
      fetch(`${process.env.REACT_APP_API_URL}/api/favorites/${userInfo.id}/${caseName}`)
        .then(response => response.json())
        .then(data => {
          setIsFavorited(data.is_favorited);
        })
        .catch((error) => {
          console.error('Error:', error);
        });

      fetch(`${process.env.REACT_APP_API_URL}/api/histories`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ user_id: userInfo.id, name: caseName, viewed_at: new Date() }),
        })
        .catch((error) => {
          console.error('Error:', error);
        });
    }
  }, [caseName, userInfo]);

  if (!product) {
    return <div css={loadingStyles}>
             <div className="dot-spin"></div>
           </div>;
  }

  const handleThumbnailClick = (index) => {
    setDisplayImage(product.image_urls[index]);
  };

  const toggleFavorites = () => {
    const method = isFavorited ? 'DELETE' : 'POST';
    const message = isFavorited ? 'お気に入りを解除しました' : 'お気に入りに追加しました';

    fetch(`${process.env.REACT_APP_API_URL}/api/favorites/${userInfo.id}/${product.name}`, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ product_id: product.name }),
    })
    .then(response => {
      if (response.ok) {
        setIsFavorited(!isFavorited);
        alert(message);
      } else {
        alert('エラーが発生しました');
      }
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  };

  return (
    <>
      <div css={containerStyles}>
        <div css={thumbnailContainerStyles}>
          <Carousel showStatus={false} showIndicators={false} showThumbs={false}>
            {product && product.thumbnail_urls.map((thumbnail, index) => (
              <div key={index} onClick={() => handleThumbnailClick(index)} css={thumbnailStyles}>
                <img
                  src={thumbnail}
                  alt={`thumbnail-${index}`}
                />
              </div>
            ))}
          </Carousel>
          <p css={hideOnDesktop}>全ての画像を見る ({imageCount})</p>
        </div>

        <div css={imageContainerStyles}>
          <img src={displayImage} alt={product.name} css={imageStyles} />
        </div>

        <div css={detailContainerStyles}>
          <h2 css={productNameStyles}>{product.name}</h2>
          <p css={productDetailStyles}>カラー：{product.color}</p>
          <p css={productDetailStyles}>メーカー：{product.maker}</p>

          <div>
            <span>価格(税込): </span>
            <span css={productPrice}>{product.price}</span>
          </div>

          <p>最終確認日: {new Date(product.checked_at).toLocaleString()}</p>

          {userInfo && userInfo.id && (
            <CustomButton
              onClick={() => {toggleFavorites()}}
              disabled={false}
              text={isFavorited ? 'お気に入りを解除' : 'お気に入りに登録'}
              Icon={MdFavorite}
              iconColor={isFavorited ? 'red' : 'white'}
              iconPosition='14px'
            />
          )}

          <CustomButton
            onClick={() => {
              const newWindow = window.open(product.ec_site_url, '_blank');
              if (newWindow) newWindow.opener = null;
            }}
            text="ショップに行く"
            Icon={BsShop}
            iconPosition='14px'
          />
        </div>
      </div>
    </>
  );
}

export default ProductDetailPage;

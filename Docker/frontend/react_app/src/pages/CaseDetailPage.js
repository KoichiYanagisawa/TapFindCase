/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { Carousel } from 'react-responsive-carousel';
import { useSelector } from 'react-redux';
import 'react-responsive-carousel/lib/styles/carousel.min.css';
import { usePageTitle } from '../contexts/PageTitle';

import Header from '../components/Header';
import Footer from '../components/Footer';
import CustomButton from '../components/CustomButton';
import { MdFavorite } from 'react-icons/md';
import { BsShop } from 'react-icons/bs';

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

const favoriteIconStyles = css`
  position: absolute;
  right: 15%;
  bottom: 5%;
  color: red;
  font-size: 4.5rem;
  @media (max-width: 1024px) {
    font-size: 3.5rem;
  }
  @media (max-width: 768px) {
    font-size: 2.5rem;
  }
  @media (max-width: 640px) {
    font-size: 2rem;
  }
  @media (max-width: 320px) {
    font-size: 1.5rem;
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
  const userInfo = useSelector((state) => state.userInfo); // useSelectorフックを使ってStoreからユーザー情報を取得
  const [product, setProduct] = useState(null);
  const [displayImage, setDisplayImage] = useState(null);
  const { id } = useParams();
  const [isFavorited, setIsFavorited] = useState(false);
  const { setPageTitle } = usePageTitle();
  setPageTitle('ー商品詳細');



  useEffect(() => {
    fetch(`http://localhost:3000/products/detail/${id}`)
      .then(response => response.json())
      .then(data => {
        setProduct(data);
        setDisplayImage(data.images[0]);
      });

    fetch(`http://localhost:3000/api/favorites/${userInfo.id}/${id}`)
      .then(response => response.json())
      .then(data => {
        setIsFavorited(data.is_favorited);
      })
      .catch((error) => {
        console.error('Error:', error);
      });

    fetch(`http://localhost:3000/api/history`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ user_id: userInfo.id, product_id: id }),
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  }, [id, userInfo.id]);

  if (!product) {
    return <div>Loading...</div>;
  }

  const imageCount = product.thumbnails.length;

  const handleThumbnailClick = (index) => {
    setDisplayImage(product.images[index]);
  };

  const toggleFavorites = () => {
    const method = isFavorited ? 'DELETE' : 'POST';
    const message = isFavorited ? 'お気に入りを解除しました' : 'お気に入りに追加しました';

    fetch(`http://localhost:3000/api/favorites/${userInfo.id}/${product.product.id}`, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ product_id: product.product.id }),
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
      <Header />
      <div css={containerStyles}>
        <div css={thumbnailContainerStyles}>
          <Carousel showStatus={false} showIndicators={false} showThumbs={false}>
            {product.thumbnails.map((thumbnail, index) => (
              <div key={index} onClick={() => handleThumbnailClick(index)} css={thumbnailStyles}>
                <img
                  src={`data:image/jpeg;base64,${thumbnail}`}
                  alt={`thumbnail-${index}`}
                />
              </div>
            ))}
          </Carousel>
          <p css={hideOnDesktop}>全ての画像を見る ({imageCount})</p>
        </div>

        <div css={imageContainerStyles}>
          <img src={`data:image/jpeg;base64,${displayImage}`} alt={product.product.name} css={imageStyles} />
          {isFavorited && <MdFavorite css={favoriteIconStyles} />}
        </div>

        <div css={detailContainerStyles}>
          <h2 css={productNameStyles}>{product.product.name}</h2>
          <p css={productDetailStyles}>カラー：{product.product.color}</p>
          <p css={productDetailStyles}>メーカー：{product.product.maker}</p>

          <div>
            <span>価格(税込): </span>
            <span css={productPrice}>{product.product.price}</span>
          </div>

          <p>最終確認日: {new Date(product.product.checked_at).toLocaleString()}</p>

          <CustomButton
            onClick={() => {toggleFavorites()}} // 実際にお気に入りに登録する処理をここに書く
            disabled={false} // 実際には条件によってtrueにする必要があるかもしれません
            text={isFavorited ? 'お気に入りを解除' : 'お気に入りに登録'}
            Icon={MdFavorite}
            iconColor={isFavorited ? 'red' : 'white'}
            iconPosition='14px'
          />

          <CustomButton
            onClick={() => {
              const newWindow = window.open(product.product.ec_site_url, '_blank');
              if (newWindow) newWindow.opener = null;
            }}
            text="ショップに行く"
            Icon={BsShop}
            iconPosition='14px'
          />
        </div>
      </div>
      <Footer />
    </>
  );
}

export default ProductDetailPage;

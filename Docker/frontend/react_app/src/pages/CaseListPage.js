/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSelector } from 'react-redux';
import Header from '../components/Header';
import Footer from '../components/Footer';

import { MdFavorite, MdFavoriteBorder } from 'react-icons/md';

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
`;

const casesContainerStyles = css`
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 20px;
  width: 100%;
`;

const caseStyles = css`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  border: 1px solid #ccc;
  border-radius: 5px;
  padding: 20px;
  box-sizing: border-box;
  background-color: #f9f9f9;
  width: 200px;

  h2, p {
    font-size: 1rem;
  }

  @media (max-width: 640px) {
    width: 45%;

    h2, p {
      font-size: 0.7rem;
    }
  }

  @media (max-width: 320px) {
    width: 100%;

    h2, p {
      font-size: 0.7rem;
    }
  }
`;

const thumbnailContainerStyles = css`
  position: relative;
  width: 100%;
`;

const imageStyles = css`
  width: 100%;
  height: auto;
`;

const favoriteIconStyles = (isFavorite) => css`
  position: absolute;
  bottom: 5%;
  right: 5%;
  color: ${isFavorite ? '#ff0000' : '#000'};
  font-size: 1.5rem;
  cursor: pointer;
`;

const casesPrice = css`
  color: #ff0000;
  font-size: 1.5rem;
  font-weight: bold;
`;

function CaseListPage({apiPath = 'favorite/1'}) {
  const userInfo = useSelector((state) => state.userInfo);
  const [cases, setCases] = useState([]);
  const [favorites, setFavorites] = useState([]); // お気に入り商品のIDを格納する配列を追加
  // const { model } = useParams();
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const loader = useRef(null);
  const navigate = useNavigate();

  const handleScroll = useCallback((entries) => {
    const target = entries[0];
    if (target.isIntersecting && hasMore) {
      setPage((prevPage) => prevPage + 1);
    }
  }, [hasMore]);

  useEffect(() => {
    const options = {
      root: null,
      rootMargin: "20px",
      threshold: 1.0
    };
    const observer = new IntersectionObserver(handleScroll, options);
    if (loader.current) {
      observer.observe(loader.current);
    }
  }, [handleScroll]);

  useEffect(() => {
    fetch(`http://localhost:3000/api/favorites/user/${userInfo.id}`)
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(data => {
        setFavorites(data.favorites);
      })
      .catch(error => console.error(error));
  }, [userInfo.id]);

  useEffect(() => {
    fetch(`http://localhost:3000/products/list/${apiPath}?page=${page}&limit=20`)
      .then(response => response.json())
      .then(data => {
        if (data.length > 0) {
          setCases(prevCases => [...prevCases, ...data]);
        } else {
          setHasMore(false);
        }
      });
  }, [apiPath, page]);

  const toggleFavorite = (productId) => {
    if(favorites.includes(productId)) {
      fetch(`http://localhost:3000/api/favorites/${userInfo.id}/${productId}`, {
        method: 'DELETE'
      })
      .then(() => {
        setFavorites(prevFavorites => prevFavorites.filter(id => id !== productId));
      });
    } else {
      fetch(`http://localhost:3000/api/favorites/${userInfo.id}/${productId}`, {
        method: 'POST'
      })
      .then(() => {
        setFavorites(prevFavorites => [...prevFavorites, productId]);
      });
    }
  };


  return (
    <>
      <Header />
      <div css={containerStyles}>
        <div css={casesContainerStyles}>
        {cases.map((caseItem, index) => {
          const isFavorite = favorites.includes(caseItem.id);

          return (
            <div
              css={caseStyles}
              key={index}
              onClick={() => navigate(`/product/detail/${caseItem.id}`)}
            >
              <div css={thumbnailContainerStyles}>
                <img src={`data:image/jpeg;base64,${caseItem.thumbnail_url}`} alt={caseItem.name} css={imageStyles} />
                {isFavorite
                  ? <MdFavorite css={favoriteIconStyles(isFavorite)} onClick={(e) => { e.stopPropagation(); toggleFavorite(caseItem.id); }} />
                  : <MdFavoriteBorder css={favoriteIconStyles(isFavorite)} onClick={(e) => { e.stopPropagation(); toggleFavorite(caseItem.id); }} />
                }
              </div>
              <h2>{caseItem.name}</h2>
              <p>{caseItem.color}</p>
              <p css={casesPrice}>{caseItem.price}</p>
            </div>
          );
        })}
          {hasMore && (
            <div ref={loader}>
              <h2>Loading...</h2>
            </div>
          )}
        </div>
      </div>
      <Footer />
    </>
  );
}

export default CaseListPage;

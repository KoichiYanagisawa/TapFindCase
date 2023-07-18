/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSelector } from 'react-redux';

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

function CaseListPage({apiPath}) {
  const userInfo = useSelector((state) => state.userInfo);
  const [cases, setCases] = useState([]);
  const [favorites, setFavorites] = useState([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [loading, setLoading] = useState(false);
  const [initialLoad, setInitialLoad] = useState(true);
  const loader = useRef(null);
  const navigate = useNavigate();

  const fetchCases = useCallback(() => {
    if (loading || !hasMore) return;
    setLoading(true);

    fetch(`http://localhost:3000/products/list/${apiPath}?page=${page}&limit=20`)
      .then(response => response.json())
      .then(data => {
        if (data.length > 0) {
          setCases(prevCases => [...prevCases, ...data]);
          setPage(prevPage => prevPage + 1);
        } else {
          setHasMore(false);
        }
      })
      .catch(error => console.error(error))
      .finally(() => setLoading(false));
  }, [apiPath, page, loading, hasMore]);

  const handleScroll = useCallback((entries) => {
    const target = entries[0];
    if (target.isIntersecting) {
      fetchCases();
    }
  }, [fetchCases]);

  useEffect(() => {
    const options = {
      root: null,
      rootMargin: "20px",
      threshold: 1.0
    };
    const observer = new IntersectionObserver(handleScroll, options);

    const currentLoader = loader.current;
    if (currentLoader) {
      observer.observe(currentLoader);
    }

    return () => {
      if (currentLoader){
        observer.unobserve(currentLoader);
      }
    };
  }, [handleScroll, loader]);


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
      })
      .catch(error => console.error(error));
    }
  };

  useEffect(() => {
  if (initialLoad) {
    setInitialLoad(false);
  }
}, [initialLoad]);


  return (
    <div css={containerStyles}>
      <div id="caseListContainer" css={casesContainerStyles}>
      {cases.map((caseItem) => {
        const isFavorite = favorites.includes(caseItem.id);

        return (
          <div
            css={caseStyles}
            key={caseItem.id}
            onClick={() => navigate(`/product/detail/${caseItem.id}`)}
          >
            <div css={thumbnailContainerStyles}>
              <img src={caseItem.thumbnail_url} alt={caseItem.name} css={imageStyles} />
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
  );
}

export default CaseListPage;

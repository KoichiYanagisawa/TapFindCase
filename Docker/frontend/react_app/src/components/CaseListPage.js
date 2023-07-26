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
  // const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [loading, setLoading] = useState(false);
  const [initialLoad, setInitialLoad] = useState(true);
  const [lastKey, setLastKey] = useState(null);
  const loader = useRef(null);
  const navigate = useNavigate();

  const fetchCases = useCallback(() => {
    if (loading || !hasMore) return;
    setLoading(true);

    let url = `${process.env.REACT_APP_API_URL}/products/list/${apiPath}?limit=20`;
    if (lastKey) url += `&last_evaluated_key=${encodeURIComponent(JSON.stringify(lastKey))}`;

    fetch(url)
    .then(response => response.json())
    .then(data => {
      if (data.products.length > 0) {
        setCases(prevCases => [...prevCases, ...data.products]);
        setLastKey(data.last_evaluated_key);
      }
      if(data.products.length < 20 || !data.last_evaluated_key){
        setHasMore(false);
      }
    })
    .catch(error => console.error(error))
    .finally(() => setLoading(false));
  }, [apiPath, loading, hasMore, lastKey]);

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
    fetch(`${process.env.REACT_APP_API_URL}/api/favorites/user/${userInfo.id}`)
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

  const toggleFavorite = (productName) => {
    if(favorites.includes(productName)) {
      fetch(`${process.env.REACT_APP_API_URL}/api/favorites/${userInfo.id}/${productName}`, {
        method: 'DELETE'
      })
      .then(() => {
        setFavorites(prevFavorites => prevFavorites.filter(name => name !== productName));
      });
    } else {
      fetch(`${process.env.REACT_APP_API_URL}/api/favorites/${userInfo.id}/${productName}`, {
        method: 'POST'
      })
      .then(() => {
        setFavorites(prevFavorites => [...prevFavorites, productName]);
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
        const isFavorite = favorites.includes(caseItem.name);

        return (
          <div
            css={caseStyles}
            key={caseItem.PK}
            onClick={() => navigate(`/product/detail/${caseItem.name}`)}
          >
            <div css={thumbnailContainerStyles}>
              <img src={caseItem.thumbnail_url} alt={caseItem.name} css={imageStyles} />
              {isFavorite
                ? <MdFavorite css={favoriteIconStyles(isFavorite)} onClick={(e) => { e.stopPropagation(); toggleFavorite(caseItem.name); }} />
                : <MdFavoriteBorder css={favoriteIconStyles(isFavorite)} onClick={(e) => { e.stopPropagation(); toggleFavorite(caseItem.name); }} />
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

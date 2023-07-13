/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Header from '../components/Header';
import Footer from '../components/Footer';

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

const imageStyles = css`
  width: 100%;
  height: auto;
`;

const casesPrice = css`
  color: #ff0000;
  font-size: 1.5rem;
  font-weight: bold;
`;

function CaseListPage() {
  const [cases, setCases] = useState([]);
  const { model } = useParams();
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true); // 新しい状態を追加
  const loader = useRef(null);
  const navigate = useNavigate(); // useNavigateフックのインスタンスを作成

  const handleScroll = useCallback((entries) => {
    const target = entries[0];
    if (target.isIntersecting && hasMore) { // hasMoreがtrueの時だけページ番号を増やす
      setPage((prevPage) => prevPage + 1);
    }
  }, [hasMore]); // 依存配列にhasMoreを追加

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
    fetch(`http://localhost:3000/products/models/${model}?page=${page}&limit=20`)
      .then(response => response.json())
      .then(data => {
        if (data.length > 0) {
          setCases(prevCases => [...prevCases, ...data]);
        } else {
          setHasMore(false); // 新たに取得したデータがない場合、hasMoreをfalseに設定
        }
      });
  }, [model, page]);


  return (
    <>
      <Header />
      <div css={containerStyles}>
        <div css={casesContainerStyles}>
          {cases.map((caseItem, index) => (
            <div
              css={caseStyles}
              key={index}
              onClick={() => navigate(`/product/detail/${caseItem.id}`)} // onClickで商品詳細ページへのリンクを追加
            >
              <img src={`data:image/jpeg;base64,${caseItem.thumbnail_url}`} alt={caseItem.name} css={imageStyles} />
              <h2>{caseItem.name}</h2>
              <p>{caseItem.color}</p>
              <p css={casesPrice}>{caseItem.price}</p>
            </div>
          ))}
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

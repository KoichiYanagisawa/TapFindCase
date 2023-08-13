/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useMemo, useEffect } from 'react';
import { useParams, useLocation } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { usePageTitle } from '../contexts/PageTitle';
import CaseListPage from '../components/CaseListPage';
import '../styles/three-dots.min.css';

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

function FlexibleListPage() {
  const params = useParams();
  const location = useLocation();
  const userInfo = useSelector((state) => state.userInfo);
  const userInfoLoading = useSelector((state) => state.userInfoLoading);
  const modelType = window.location.pathname.split('/')[1];
  const { setPageTitle } = usePageTitle();

  useEffect(() => {
    if (modelType === 'product') {
      setPageTitle('ー製品一覧');
    } else if (modelType === 'favorite') {
      setPageTitle('ーお気に入り');
    } else if (modelType === 'history') {
      setPageTitle('ー閲覧履歴');
    }
  }, [modelType, setPageTitle]);

  const apiPath = useMemo(() => {
    switch (modelType) {
      case 'product':
        return `${params.model}`;
      case 'favorite':
        sessionStorage.removeItem('caseListPageState');
        return userInfo ? `favorite/${userInfo.id}` : null;
      case 'history':
        sessionStorage.removeItem('caseListPageState');
        return userInfo ? `history/${userInfo.id}`: null;
      default:
        return `/`;
    }
  }, [modelType, params.model, userInfo]);

  if (userInfoLoading) {
    return <div css={loadingStyles}><div className="dot-spin"></div></div>;
  }

  return (
    <div>
      <CaseListPage key={location.pathname} apiPath={encodeURIComponent(apiPath)} />
    </div>
  );
}

export default FlexibleListPage;

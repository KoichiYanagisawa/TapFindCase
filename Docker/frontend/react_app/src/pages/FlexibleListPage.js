import React, { useMemo, useEffect } from 'react';
import { useParams, useLocation } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { usePageTitle } from '../contexts/PageTitle';
import Header from '../components/Header';
import CaseListPage from '../components/CaseListPage';
import Footer from '../components/Footer';

function FlexibleListPage() {
  const params = useParams();
  const location = useLocation();
  const userInfo = useSelector((state) => state.userInfo);
  const modelType = window.location.pathname.split('/')[1];
  const { setPageTitle } = usePageTitle();

  useEffect(() => {
    if (modelType === 'product') {
      setPageTitle('ー製品一覧');
    } else if (modelType === 'favorite') {
      setPageTitle('ーお気に入り一覧');
    } else if (modelType === 'history') {
      setPageTitle('ー閲覧履歴');
    }
  }, [modelType, setPageTitle]);

  const apiPath = useMemo(() => {
    switch (modelType) {
      case 'product':
        return `${params.model}`;
      case 'favorite':
        return `favorite/${userInfo.id}`;
      case 'history':
        return `history/${userInfo.id}`;
      default:
        return `/`;
    }
  }, [modelType, params.model, userInfo.id]);

  return (
    <div>
      <Header model={params.model} />
      <CaseListPage key={location.pathname} apiPath={apiPath} />
      <Footer />
    </div>
  );
}

export default FlexibleListPage;

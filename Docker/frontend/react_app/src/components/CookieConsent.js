/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState, useEffect } from 'react';
import { useDispatch } from 'react-redux';
import axios from 'axios';
import Cookies from 'js-cookie';
import { v4 as uuidv4 } from 'uuid';

const consentContainer = css`
  position: fixed;
  bottom: 20px;
  width: 100%;
  background: #d3d3d3;
  padding: 20px;
  text-align: center;
`;

const buttonContainer = css`
  display: inline-block; // ボタンを横に並べるためのスタイル
`;

const buttonCommonStyles = css`
  margin-top: 10px;
  padding: 10px 20px;
  border: none;
  color: white;
  text-align: center;
  text-decoration: none;
  display: inline-block; // ボタンを横に並べるためのスタイル
  font-size: 1.2rem;
  transition-duration: 0.4s;
  cursor: pointer;
  width: 150px; // ボタンの幅を固定
  margin-right: 10px; // ボタン間のスペース
`;

const consentButton = css`
  background-color: #4CAF50;
  &:hover {
    background-color: #45a049;
  }
`;

const declineButton = css`
  background-color: #f44336;
  &:hover {
    background-color: #d32f2f;
  }
`;

const privacyPolicy = css`
  color: blue;
  cursor: pointer;
`;

function CookieConsent({onPrivacyClick}) {
  const dispatch = useDispatch();

  const hasGivenConsent = Cookies.get('hasGivenConsent');
  const [visible, setVisible] = useState(!hasGivenConsent);

  const handleConsent = () => {
    setVisible(false);
    let userId = Cookies.get('userId');

    if (!userId) {
      userId = uuidv4();
      Cookies.set('userId', userId, { expires: 365 });
    }

    Cookies.set('hasGivenConsent', 'true', { expires: 365 });

    axios.get(`${process.env.REACT_APP_API_URL}/api/users/${userId}`)
      .then((response) => {
        dispatch({
          type: 'SET_USER_INFO',
          payload: response.data
        });
      })
      .catch((error) => {
        console.error(`Failed to fetch user info: ${error}`);
      });
  };

  const handleDecline = () => {
    setVisible(false);
  };

  useEffect(() => {
    if (!visible) {
      dispatch({
        type: 'SET_USER_CONSENT',
        payload: false
      });
    }
  }, [visible, dispatch]);

  if (!visible) return null;

  return (
    <div css={consentContainer}>
      <p>当サイトはユーザーエクスペリエンスの向上のためにCookieを使用しています。Cookieの保存に同意しますか？</p>
      <p>詳細は<span css={privacyPolicy} onClick={onPrivacyClick}>プライバシーポリシー</span>をご覧ください。</p>
      <div css={buttonContainer}>
        <button css={[consentButton, buttonCommonStyles]} onClick={handleConsent}> 同意する </button>
        <button css={[declineButton, buttonCommonStyles]} onClick={handleDecline}>同意しない</button>
      </div>
    </div>
  );
}

export default CookieConsent;

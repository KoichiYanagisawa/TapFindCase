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

const consentButton = css`
  margin-top: 10px;
  padding: 10px 20px;
  background-color: #4CAF50; /* Green */
  border: none;
  color: white;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  transition-duration: 0.4s;
  cursor: pointer;

  &:hover {
    background-color: #45a049;
  }
`;

const declineButton = css`
  margin-top: 10px;
  padding: 10px 20px;
  background-color: #f44336; /* Red */
  border: none;
  color: white;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  transition-duration: 0.4s;
  cursor: pointer;
  margin-left: 10px;

  &:hover {
    background-color: #d32f2f;
  }
`;

function CookieConsent() {
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
      <p>当サイトはユーザーエクスペリエンスの向上のためにCookieを使用しています。詳細は<a href="/privacy">プライバシーポリシー</a>をご覧ください。</p>
      <button css={consentButton} onClick={handleConsent}>同意する</button>
      <button css={declineButton} onClick={handleDecline}>同意しない</button>
    </div>
  );
}

export default CookieConsent;

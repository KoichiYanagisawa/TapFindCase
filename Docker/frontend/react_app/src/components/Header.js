/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState, useRef, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { usePageTitle } from '../contexts/PageTitle';

const headerStyles = css`
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  height: 60px;
  padding: 0 20px;
  background-color: black;
  color: white;
  font-size: 45px;
  position: fixed;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  z-index: 1000;

  @media (max-width: 600px) {
    font-size: 35px;
  }

  @media (max-width: 450px) {
    font-size: 25px;
  }
`;

const titleStyles = css`
  cursor: pointer;
`;

const hamburgerStyles = props => css`
  width: 30px;
  height: 2px;
  background-color: ${props.isMenuOpen ? "transparent" : "white"};
  position: relative;
  transition: all 0.3s linear;
  align-self: center;

  &::before,
  &::after {
    content: '';
    position: absolute;
    width: 30px;
    height: 2px;
    background-color: white;
    transition: all 0.3s linear;
  }

  &::before {
    transform: ${props.isMenuOpen ? 'rotate(-45deg) translateY(0)' : 'rotate(0) translateY(-10px)'};
  }

  &::after {
    transform: ${props.isMenuOpen ? 'rotate(45deg) translateY(0)' : 'rotate(0) translateY(10px)'};
  }
`;

const menuStyles = props => css`
  position: fixed;
  right: 0;
  top: 60px;
  transform : translateX(${props.isMenuOpen ? "0" : "100%"});
  width: 70%;
  max-width: 250px;
  height: 100vh;
  display: flex;
  flex-direction: column;
  color: #fff;
  background-color: rgba(0, 0, 0, 0.7);
  transition: transform .3s;

  @media (max-width: 600px) {
    max-width: 200px;
  }

  @media (max-width: 450px) {
    max-width: 150px;
  }
`;

const menuItemStyles = css`
  width: 100%;
  padding: 20px 0;
  text-align: center;
  font-size: 0.5em;
  white-space: nowrap;
  border-bottom: 1px solid #fff;
  &:last-child {
    border-bottom: 0;
  }

  &:hover {
    color: #fff;
    background-color: rgba(0, 0, 0, 0.7);
    cursor: pointer;
  }
`;

const hamburgerContainerStyles = css`
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
`;

function Header({ model, onTermsClick, onPrivacyClick }) {
  const userInfo = useSelector(state => state.userInfo);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const navigate = useNavigate();
  const { pageTitle } = usePageTitle();
  const menuRef = useRef(null);
  const hamburgerContainerRef = useRef(null);

  const handleMenuClick = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  const handleHomeClick = () => {
    navigate("/");
    setIsMenuOpen(false);
  };

  const handleFavoriteClick = () => {
    navigate("/favorite");
    setIsMenuOpen(false);
  };

  const handleHistoryClick = () => {
    navigate("/history");
    setIsMenuOpen(false);
  };

  const handleClickOutside = (event) => {
    if (hamburgerContainerRef.current && hamburgerContainerRef.current.contains(event.target)) {
      return;
    }
    if (menuRef.current && !menuRef.current.contains(event.target)) {
      setIsMenuOpen(false);
    }
  };

  const handleMenuItemClick = (clickEvent) => {
    setIsMenuOpen(false);
    clickEvent();
  };

  useEffect(() => {
    if (isMenuOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    } else {
      document.removeEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isMenuOpen]);

  return (
    <div css={headerStyles}>
      <h1>
        <span css={titleStyles} onClick={handleHomeClick}>TapFindCase</span> {pageTitle}
      </h1>
      <div css={hamburgerContainerStyles} onClick={handleMenuClick} ref={hamburgerContainerRef}>
        <div css={hamburgerStyles({isMenuOpen})} />
      </div>

      <div css={menuStyles({isMenuOpen})} ref={menuRef}>
        <div css={menuItemStyles} onClick={() => handleMenuItemClick(handleHomeClick)}>ホーム画面</div>
        {userInfo && userInfo.id && (
          <>
            <div css={menuItemStyles} onClick={() => handleMenuItemClick(handleFavoriteClick)}>お気に入り</div>
            <div css={menuItemStyles} onClick={handleHistoryClick}>閲覧履歴</div>
          </>
        )}
        <div css={menuItemStyles} onClick={() => handleMenuItemClick(onTermsClick)}>利用規約</div>
        <div css={menuItemStyles} onClick={() => handleMenuItemClick(onPrivacyClick)}>プライバシーポリシー</div>
      </div>
    </div>
  );
}

export default Header;

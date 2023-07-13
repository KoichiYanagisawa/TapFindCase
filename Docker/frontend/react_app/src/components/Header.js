/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState } from 'react';

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
  max-width: 200px;
  height: 100vh;
  display: flex;
  flex-direction: column;
  color: #fff;
  background-color: rgba(0, 0, 0, 0.7);
  transition: transform .3s;
`;

const menuItemStyles = css`
  width: 100%;
  padding: 20px 0;
  text-align: center;
  font-size: 0.5em;
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

function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const handleMenuClick = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  return (
    <div css={headerStyles}>
      <h1>TapFindCase</h1>
      <div css={hamburgerContainerStyles} onClick={handleMenuClick}>
        <div css={hamburgerStyles({isMenuOpen})} />
      </div>

      <div css={menuStyles({isMenuOpen})}>
        <div css={menuItemStyles} onClick={handleMenuClick}>ホーム画面</div>
        <div css={menuItemStyles} onClick={handleMenuClick}>履歴</div>
        <div css={menuItemStyles} onClick={handleMenuClick}>お気に入り</div>
      </div>
    </div>
  );
}

export default Header;

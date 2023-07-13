/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React from 'react';
import { IoSearchCircleSharp } from 'react-icons/io5'; // BiChevronDownCircleアイコンをインポート

const containerStyles = css`
  width: 400px;
  display: flex;
  justify-content: center;
  align-items: center;
  @media (max-width: 450px) {
    width: 100%;
  }
`;

const buttonStyles = css`
  margin-top: 20px;
  text-align: center;
  width: 400px;
  height: 60px;
  background-color: black;
  color: white;
  border: none;
  border-radius: 30px;
  font-size: 1.25rem;
  position: relative;
  &:hover {
    background: #262626;
    cursor: pointer;
  }
  @media (max-width: 450px) {
    font-size: 1.0rem;
  }
`;

const searchIconStyles = css`
  font-size: 50px; // サイズを50pxに変更
  position: absolute;
  right: 5px;
  top: 50%;
  transform: translateY(-50%); // アイコンを垂直方向に中央に配置
`;

function SearchButton({ onClick, disabled }) {
  return (
    <div css={containerStyles}>
      <button css={buttonStyles} onClick={onClick} disabled={disabled}>
        ケースを探す
        <IoSearchCircleSharp css={searchIconStyles} />
      </button>
    </div>
  );
}

export default SearchButton;

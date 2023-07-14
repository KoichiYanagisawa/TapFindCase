/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React from 'react';

const containerStyles = css`
  max-width: 400px;
  width: 100%;
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

const getIconStyles = (position) => css`
  font-size: 50px;
  position: absolute;
  right: ${position};
  top: 50%;
  transform: translateY(-50%);
`;

function CustomButton({ onClick, disabled, text, Icon, iconPosition = '5px' }) {
  const iconStyles = getIconStyles(iconPosition);
  return (
    <div css={containerStyles}>
      <button css={buttonStyles} onClick={onClick} disabled={disabled}>
        {text}
        {Icon && <Icon css={iconStyles} />}
      </button>
    </div>
  );
}

export default CustomButton;

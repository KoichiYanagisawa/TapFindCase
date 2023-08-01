/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React from 'react';

const containerStyles = css`
  max-width: 400px;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  @media (max-width: 768px) {
    width: 250px;
  }
`;

const getButtonStyles = (style) => css`
  margin-top: 20px;
  text-align: center;
  width: 100%;
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
  @media (max-width: 1024px) {
    font-size: 1.0rem;
  }
  @media (max-width: 425px) {
    font-size: 1.0rem;
  }
  ${style}
`;

const getIconStyles = (position, iconColor) => css`
  font-size: 50px;
  position: absolute;
  right: ${position};
  color: ${iconColor};
  top: 50%;
  transform: translateY(-50%);
`;

function CustomButton({ onClick, disabled, text, style, Icon, iconColor = '#fff', iconPosition = '5px' }) {
  const buttonStyles = getButtonStyles(style);
  const iconStyles = getIconStyles(iconPosition, iconColor);
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

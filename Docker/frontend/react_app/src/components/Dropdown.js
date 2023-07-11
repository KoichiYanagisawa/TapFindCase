/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState } from 'react';
import { FaCircleChevronDown } from 'react-icons/fa6'; // BiChevronDownCircleアイコンをインポート

const dropdownContainerStyles = css`
  position: relative;
  width: 400px;
  display: flex;
  justify-content: center;
  border-radius: 30px;
`;

const dropdownHeaderStyles = css`
  height: 60px;
  width: 100%;
  border-radius: 30px;
  font-size: 20px;
  background: black;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  &:hover {
    background: #262626;
  }
`;

const dropdownListStyles = css`
  position: absolute;
  width: 100%;
  background: black;
  color: white;
  border-radius: 30px;
  z-index: 1;
  max-height: 360px; // 6つの項目に対応する高さ
  overflow-y: auto; // 縦方向にスクロール可能にする
`;

const dropdownListItemStyles = css`
  height: 60px;
  font-size: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  &:hover {
    background: gray;
    border-radius: 30px;
  }
`;

const dropdownIconStyles = css`
  color: red; // アイコンの色を赤に設定
  position: absolute;
  right: 10px;
  font-size: 40px;
`;

function Dropdown({ options, value, onChange, placeholder }) {
  const [isOpen, setIsOpen] = useState(false);

  const handleToggleDropdown = () => {
    setIsOpen(!isOpen);
  };

  const handleOptionClick = (value) => {
    onChange(value);
    setIsOpen(false);
  };

  return (
    <div css={dropdownContainerStyles}>
      <div css={dropdownHeaderStyles} onClick={handleToggleDropdown}>
        {value || placeholder}
        <FaCircleChevronDown css={dropdownIconStyles} /> {/* アイコンを追加 */}
      </div>
      {isOpen && (
        <div css={dropdownListStyles}>
          {options.map((option, index) => (
            <div
              key={index}
              css={dropdownListItemStyles}
              onClick={() => handleOptionClick(option.value)}
            >
              {option.label}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default Dropdown;

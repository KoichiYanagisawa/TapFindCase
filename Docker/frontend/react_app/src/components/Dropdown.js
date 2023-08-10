/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React, { useState, useRef, useEffect } from 'react';
import { FaCircleChevronDown } from 'react-icons/fa6';

const dropdownContainerStyles = css`
  position: relative;
  width: 100%;
  max-width: 400px;
  display: flex;
  justify-content: center;
  border-radius: 30px;
  @media (max-width: 450px) {
    width: 100%;
  }
`;

const dropdownHeaderStyles = css`
  height: 60px;
  width: 100%;
  border-radius: 30px;
  font-size: 1.25rem;
  background: black;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  &:hover {
    background: #262626;
  }

  @media (max-width: 450px) {
    font-size: 1.0rem;
  }
`;

const dropdownListStyles = css`
  position: absolute;
  width: 100%;
  background: black;
  font-size: 1.25rem;
  color: white;
  border-radius: 30px;
  z-index: 1;
  max-height: 360px;
  overflow-y: auto;
  @media (max-width: 450px) {
    font-size: 1.0rem;
  }
`;

const dropdownListItemStyles = css`
  height: 60px;
  font-size: 1.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
  &:hover {
    background: gray;
    border-radius: 30px;
  }
  @media (max-width: 450px) {
    font-size: 1.0rem;
  }
`;

const dropdownIconStyles = css`
  color: red;
  position: absolute;
  right: 10px;
  font-size: 40px;
`;

function Dropdown({ options, value, onChange, placeholder }) {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);

  const handleClickOutside = (event) => {
    if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
      setIsOpen(false);
    }
  }

  useEffect(() => {
    if (isOpen) {
      document.addEventListener('click', handleClickOutside, true);
    } else {
      document.removeEventListener('click', handleClickOutside, true);
    }
    return () => document.removeEventListener('click', handleClickOutside, true);
  }, [isOpen]);

  const handleToggleDropdown = () => {
    setIsOpen(!isOpen);
  };

  const handleOptionClick = (value) => {
    onChange(value);
    setIsOpen(false);
  };

  return (
    <div css={dropdownContainerStyles} ref={dropdownRef}>
      <div css={dropdownHeaderStyles} onClick={handleToggleDropdown}>
        {value || placeholder}
        <FaCircleChevronDown css={dropdownIconStyles} />
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

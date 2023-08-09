/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';
import React from 'react';
import ReactMarkdown from 'react-markdown';

const modalStyles = css`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 1001;
`;

const modalContentStyles = css`
  background-color: #fff;
  padding: 20px;
  border-radius: 10px;
  width: 90%;
  height: 90%;
  overflow: auto;
  position: relative;

  h1 {
    font-size: 2rem;
    padding-bottom: 10px;
  }

  h2 {
    font-size: 1.5rem;
    padding-bottom: 10px;
  }

  p {
    font-size: 1rem;
    padding-bottom: 10px;
  }

  ol {
    list-style-type: decimal;
    padding-left: 20px;
    padding-bottom: 10px;
  }

  a {
    color: blue;
    text-decoration: underline;
`;

const closeButtonStyles = css`
  position: absolute;
  top: 10px;
  right: 10px;
  cursor: pointer;
  font-size: 1.5rem;
`;

function Modal({ content, onClose }) {
  return (
    <div css={modalStyles}>
      <div css={modalContentStyles}>
        <div css={closeButtonStyles} onClick={onClose}>×</div>
        <ReactMarkdown>{content}</ReactMarkdown>
      </div>
    </div>
  );
}

export default Modal;

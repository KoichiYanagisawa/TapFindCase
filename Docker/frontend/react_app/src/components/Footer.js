/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';

const footerStyles = css`
  font-size: 10px;
  position: fixed;
  left: 0;
  bottom: 0;
  width: 100%;
  height: 20px;
  background-color: black;
  color: white;
  text-align: center;
  padding: 5px 0;
`;

function Footer() {
  return (
    <div css={footerStyles}>
      <p>© 2023 TapFindCase. All rights reserved.</p>
    </div>
  );
}

export default Footer;

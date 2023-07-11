/** @jsxImportSource @emotion/react */
import { css } from '@emotion/react';

const footerStyles = css`
  font-size: 0.8rem;
  position: fixed;
  left: 0;
  bottom: 0;
  width: 100%;
  background-color: black;
  color: white;
  text-align: center;
  padding: 10px 0;
`;

function Footer() {
  return (
    <div css={footerStyles}>
      <p>© 2023 TapFindCase. All rights reserved.</p>
    </div>
  );
}

export default Footer;

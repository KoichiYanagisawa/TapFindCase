import { createContext, useContext, useState } from 'react';

export const PageTitleContext = createContext();

export function usePageTitle() {
  return useContext(PageTitleContext);
}

export function PageTitleProvider({ children }) {
  const [pageTitle, setPageTitle] = useState('');

  return (
    <PageTitleContext.Provider value={{ pageTitle, setPageTitle }}>
      {children}
    </PageTitleContext.Provider>
  );
}

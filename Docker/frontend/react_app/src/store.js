import { configureStore } from '@reduxjs/toolkit';

const initialState = {
  userInfo: null,
  userInfoLoading: false
};

const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'SET_USER_INFO':
      return { ...state, userInfo: action.payload };
    case 'SET_USER_INFO_LOADING':
      return { ...state, userInfoLoading: action.payload };
    default:
      return state;
  }
};

const store = configureStore({
  reducer
});

export default store;

import { configureStore } from '@reduxjs/toolkit';

const initialState = {
  userInfo: null
};

const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'SET_USER_INFO':
      return { ...state, userInfo: action.payload };
    default:
      return state;
  }
};

const store = configureStore({
  reducer
});

export default store;

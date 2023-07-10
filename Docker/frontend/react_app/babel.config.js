module.exports = function(api) {
  api.cache(true);

  return {
    presets: [
      // 他のプリセットをここに追加...
      '@babel/preset-env',
      '@babel/preset-react'
    ],
    plugins: [
      // 他のプラグインをここに追加...
      'macros'
    ],
  };
};

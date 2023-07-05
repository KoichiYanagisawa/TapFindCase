FROM node:16
# ワークディレクトリを指定
WORKDIR /app
# 依存関係をインストール
COPY src/ ./
RUN npm install

# ポート3000番を開放
EXPOSE 3000

# コンテナ起動時に実行するコマンド
CMD [ "npm", "start" ]

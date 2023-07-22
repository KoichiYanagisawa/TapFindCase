FROM ruby:3.2.2

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install -y wget curl unzip xvfb libxi6 libgconf-2-4 libnss3 libasound2 fonts-liberation libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcups2 libgbm1 libgtk-3-0 libnspr4 libu2f-udev libvulkan1 libxcomposite1 libxdamage1 libxkbcommon0 xdg-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ダミーのxdg-icon-resourceコマンドを作成
RUN echo '#!/bin/bash' > /usr/bin/xdg-icon-resource && chmod +x /usr/bin/xdg-icon-resource

# ワークディレクトリの作成
WORKDIR /root/src

# ホストOS上にあるGemfileとGemfile.lockをコンテナにコピー
COPY ./src /root/src

# Bundlerで依存関係をインストール
RUN bundle install

# コンテナ起動時に実行されるコマンド
CMD ["ruby", "main.rb"]

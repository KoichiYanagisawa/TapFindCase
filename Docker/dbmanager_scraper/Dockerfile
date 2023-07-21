FROM ruby:3.2.2

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install -y wget curl unzip xvfb libxi6 libgconf-2-4 libnss3 libasound2 fonts-liberation libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcups2 libgbm1 libgtk-3-0 libnspr4 libu2f-udev libvulkan1 libxcomposite1 libxdamage1 libxkbcommon0 xdg-utils default-mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ダミーのxdg-icon-resourceコマンドを作成
RUN echo '#!/bin/bash' > /usr/bin/xdg-icon-resource && chmod +x /usr/bin/xdg-icon-resource

# Google Chromeをインストール
RUN wget -N https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P ~/
RUN (dpkg -i --force-depends ~/google-chrome-stable_current_amd64.deb || apt-get -f install -y) && apt-get clean
RUN rm ~/google-chrome-stable_current_amd64.deb

# ChromeDriverのインストール
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# ワークディレクトリの作成
WORKDIR /root/src

# ホストOS上にあるGemfileとGemfile.lockをコンテナにコピー
COPY ./src /root/src

# Bundlerで依存関係をインストール
RUN bundle install

# コンテナ起動時に実行されるコマンド
# CMD ["ruby", "main.rb"]

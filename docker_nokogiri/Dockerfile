FROM ubuntu:22.04

# ワークディレクトリの作成
WORKDIR /root/src

# ホストOS上にあるGemfileとGemfile.lockをコンテナにコピー
COPY ./src /root/src

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install -y curl build-essential zlib1g-dev libssl-dev libreadline-dev libffi-dev libyaml-dev

# Rubyのインストール
RUN curl -fsSL https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.2.tar.gz | tar -xz && \
    cd ruby-3.2.2 && \
    ./configure && make && make install && \
    cd .. && rm -rf ruby-3.2.2

# Bundlerで依存関係をインストール
RUN gem install bundler && \
    bundle install

# コンテナ起動時に実行されるコマンド
CMD ["bin/bash"]

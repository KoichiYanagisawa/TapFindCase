FROM ruby:3.2.2

# Node.jsとYarnをインストールする
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq && apt-get install -y yarn nodejs

WORKDIR /root/app
COPY ./src /root/app

RUN bundle install

FROM ubuntu:22.04

RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install -y curl git libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
RUN echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
RUN /bin/bash -l -c "rbenv install 3.2.2 && rbenv global 3.2.2"

WORKDIR /root/app

RUN /bin/bash -l -c "gem install bundler"

COPY ./app/Gemfile ./app/Gemfile.lock /root/app/

RUN /bin/bash -l -c "bundle install"

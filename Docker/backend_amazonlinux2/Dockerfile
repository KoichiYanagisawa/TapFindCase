FROM amazonlinux:2

# Install Node.js and Yarn
RUN curl --silent --location https://rpm.nodesource.com/setup_14.x | bash - \
    && curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo \
    && yum install -y nodejs yarn \
    && yum groupinstall -y "Development Tools"

# Install Ruby using rbenv
RUN yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel \
    && git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
    && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc \
    && echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
    && exec $SHELL \
    && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
    && echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc \
    && exec $SHELL \
    && rbenv install 3.2.2 \
    && rbenv global 3.2.2 \
    && gem install bundler

WORKDIR /root/app
COPY ./src /root/app

# RUN /root/.rbenv/shims/bundle install

# CMD ["/root/.rbenv/shims/rails", "s", "-b", "0.0.0.0"]

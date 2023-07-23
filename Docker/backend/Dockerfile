FROM amazonlinux:2

# Install Node.js and Yarn
RUN curl --silent --location https://rpm.nodesource.com/setup_14.x | bash - \
    && curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo \
    && yum install -y nodejs yarn \
    && yum groupinstall -y "Development Tools"

# Install Ruby using rbenv
RUN yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel libyaml libyaml-devel \
    && git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
    && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
    && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc \
    && echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc \
    && echo 'eval "$(rbenv init -)"' >> ~/.bashrc

RUN source ~/.bashrc \
    && /bin/bash -l -c "rbenv install 3.2.2" \
    && /bin/bash -l -c "rbenv global 3.2.2" \
    && /bin/bash -l -c "gem install bundler"

WORKDIR /root/app
COPY ./src /root/app

RUN /bin/bash -l -c "/root/.rbenv/shims/bundle install"

# CMD ["/bin/bash", "rails s -b 0.0.0.0"]

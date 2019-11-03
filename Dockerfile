FROM ruby:2.6.5

SHELL [ "/bin/bash", "-l", "-c" ]

RUN apt update && apt install curl -y

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash

WORKDIR /usr/src/time_clock

COPY . .

RUN nvm install && npm install -g yarn && yarn install

RUN gem install bundler && bundle install

CMD bundle && yarn install && rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0

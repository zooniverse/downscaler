FROM ruby:3.4
WORKDIR /app

RUN curl -LO https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm -f ./kubectl

ADD ./Gemfile /app/
ADD ./Gemfile.lock /app/

RUN bundle install

ADD ./ /app

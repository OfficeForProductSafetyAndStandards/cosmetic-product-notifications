FROM ruby:2.5.5

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y \
  build-essential \
  nodejs \
  yarn

WORKDIR /cosmetics-web

COPY ./cosmetics-web .
COPY ./shared-web ./vendor/shared-web

COPY ./cosmetics-worker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

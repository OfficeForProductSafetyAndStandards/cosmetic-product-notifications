FROM ruby:2.4.3

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential nodejs

RUN mkdir /app
WORKDIR /app

COPY . .

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

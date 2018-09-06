FROM ruby:2.4.4

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  nodejs \
  clamav \
  clamav-daemon

RUN freshclam
RUN service clamav-daemon restart

RUN mkdir /app
WORKDIR /app

COPY . .

COPY ./worker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

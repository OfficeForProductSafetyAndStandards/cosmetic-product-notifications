FROM ruby:3.2.2

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV CHROMIUM_DRIVER_VERSION 2.41

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main"  | tee /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get install -y \
  build-essential \
  nodejs \
  yarn \
  unzip \
  google-chrome-stable

RUN curl -o /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$CHROMIUM_DRIVER_VERSION/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver.zip chromedriver -d /usr/bin/ \
  && rm /tmp/chromedriver.zip \
  && chmod ugo+rx /usr/bin/chromedriver

EXPOSE 3000
WORKDIR /cosmetics-web

COPY ./cosmetics-web .

RUN yarn install
RUN gem update --system '3.4.4'
RUN bin/bundle check || bin/bundle install
RUN yarn build

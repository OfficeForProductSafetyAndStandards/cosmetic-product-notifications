FROM ruby:2.5.3

WORKDIR /psd-web

COPY ./psd-web .
COPY ./shared-web ./vendor/shared-web

COPY ./psd-worker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

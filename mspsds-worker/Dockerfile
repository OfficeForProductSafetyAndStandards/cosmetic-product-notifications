FROM ruby:2.5.3

WORKDIR /mspsds-web

COPY ./mspsds-web .
COPY ./shared-web ./vendor/shared-web

COPY ./mspsds-worker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

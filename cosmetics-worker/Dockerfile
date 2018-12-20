FROM ruby:2.5.3

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  nodejs \
  clamav \
  clamav-daemon

# Run ClamAV as root to avoid permissions issues
RUN sed -i 's/User clamav/User root/g' /etc/clamav/clamd.conf

WORKDIR /cosmetics-web

COPY ./cosmetics-web .
COPY ./shared-web ./vendor/shared-web

COPY ./cosmetics-worker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

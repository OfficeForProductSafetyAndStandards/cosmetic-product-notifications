FROM node:10

WORKDIR /maintenance

COPY ./maintenance .

COPY ./maintenance/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]

FROM postgres

WORKDIR /docker-entrypoint-initdb.d

COPY setup-keycloak.sh .

# These allow pgHero to use pt_stat_statements in dev mode
RUN echo "shared_preload_libraries = 'pg_stat_statements'" >> /var/lib/postgresql/data/postgresql.conf
RUN echo "pg_stat_statements.track = all" >> /var/lib/postgresql/data/postgresql.conf
RUN echo "pg_stat_statements.max = 10000" >> /var/lib/postgresql/data/postgresql.conf
RUN echo "track_activity_query_size = 2048" >> /var/lib/postgresql/data/postgresql.conf

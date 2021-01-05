FROM postgres:10.5

WORKDIR /docker-entrypoint-initdb.d

# Adds configuration to the postgres server to allow pgHero to see query stats
COPY setup-pgHero.sh .

# Enables citext extension for case insensitive columns
COPY enable-citext-extension.sql /docker-entrypoint-initdb.d/enable-citext-extension.sql

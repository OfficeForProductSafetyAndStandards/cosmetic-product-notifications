FROM postgres:10.5

WORKDIR /docker-entrypoint-initdb.d

COPY setup-keycloak.sh .

# Adds configuration to the postgres server to allow pgHero to see query stats
COPY setup-pgHero.sh .

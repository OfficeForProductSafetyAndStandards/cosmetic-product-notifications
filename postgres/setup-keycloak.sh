#!/bin/bash
set -ex

# Create the database and user required by Keycloak

psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
  CREATE DATABASE keycloak;
  CREATE USER keycloak WITH ENCRYPTED PASSWORD 'password';
  GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
EOSQL

#!/usr/bin/env bash
set -ex

# This is the CI server script to package and deploy Keycloak
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# SPACE: the space to which you want to deploy
# If NO_START is set the app won't be started


docker build --target keycloak-package -t keycloak-package:latest ./keycloak
docker cp $(docker create keycloak-package):/tmp/keycloak/package ./keycloak

cf push -f ./keycloak/manifest.yml --hostname keycloak-$SPACE $( [[ ${NO_START} ]] && printf %s '--no-start' )

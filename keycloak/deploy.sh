#!/usr/bin/env bash
set -ex

# This is the CI server script to package and deploy Keycloak
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# CF_USERNAME: cloudfoundry username
# CF_PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

docker build --target keycloak-package -t keycloak-package:latest ./keycloak
docker cp $(docker create keycloak-package):/tmp/keycloak/package ./keycloak

# Install the Cloud Foundry CLI
./ci/install-cf.sh

cf login -a api.cloud.service.gov.uk -u $CF_USERNAME -p $CF_PASSWORD -o 'beis-mspsds' -s $SPACE

cf push -f ./keycloak/manifest.yml

cf logout

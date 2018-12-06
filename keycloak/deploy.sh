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
#
# If SET_UP is set the script will omit installing cf cli and logging in and out
# This can be used to invoke the script from dev machines when performing initial setup


docker build --target keycloak-package -t keycloak-package:latest ./keycloak
docker cp $(docker create keycloak-package):/tmp/keycloak/package ./keycloak

# Install the Cloud Foundry CLI

if [[ -z ${SET_UP} ]] ; then
    ./ci/install-cf.sh
    cf login -a api.london.cloud.service.gov.uk -u $CF_USERNAME -p $CF_PASSWORD -o 'beis-mspsds' -s $SPACE
    cf push -f ./keycloak/manifest.yml
    cf logout
fi
if [[ ${SET_UP} ]] ; then
    cf push -f ./keycloak/manifest.yml --no-start --hostname keycloak-$SPACE
fi

#!/bin/bash
set -ex

# This is the CI server script to package and deploy Keycloak
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# USERNAME: cloudfoundry username
# PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

./keycloak/build-notify.sh
./keycloak/build-theme.sh

# Download and configure the Keycloak package
./keycloak/package.sh

# Install the Cloud Foundry CLI
./shared/install-cf.sh

cf login -a api.cloud.service.gov.uk -u $USERNAME -p $PASSWORD -o "beis-mspsds" -s $SPACE

cf push -f ./keycloak/manifest.yml

cf logout

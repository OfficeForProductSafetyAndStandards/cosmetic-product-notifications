#!/usr/bin/env bash
set -ex

# This is the CI server script to package and deploy the Keycloak app
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# USERNAME: cloudfoundry username
# PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

# Download and configure the Keycloak package
./keycloak/scripts/package-keycloak.sh

# Install the Cloud Foundry CLI
./infrastructure/scripts/install-cf.sh

# Push the package files to the Cloud Foundry app
[[ -v SPACE ]] || read -p "Which space? (int,staging,live): " SPACE
case ${SPACE} in
  int | staging )
    HOSTNAME=keycloak-${SPACE}
  ;;
  live )
    HOSTNAME=keycloak
  ;;
  * )
    echo "Bad space value"
    exit 1
  ;;
esac

cf login -a api.cloud.service.gov.uk -u ${USERNAME} -p ${PASSWORD} -o "beis-mspsds" -s ${SPACE}

cf push $HOSTNAME -f ./keycloak/manifest.yml

cf logout

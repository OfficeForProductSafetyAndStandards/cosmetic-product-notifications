#!/usr/bin/env bash
set -ex

# This is the CI server script to package and deploy Keycloak
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# SPACE: the space to which you want to deploy

DOMAIN=opss-access.service.gov.uk
if [[ $SPACE == "prod" ]]; then
    HOSTNAME=www
elif [[ $SPACE == "research" ]]; then
    HOSTNAME="keycloak-research"
    DOMAIN=london.cloudapps.digital
else
    HOSTNAME=$SPACE
fi
APP=keycloak
APP_PREEXISTS=$(cf app $APP && echo 0 || echo 1)

if [[ $APP_PREEXISTS ]]; then
    # We should deploy to a temporary location such that we can do a blue-green deployment
    NEW_HOSTNAME=$HOSTNAME-temp
    NEW_APP=$APP-temp
else
    # We don't need to deploy to a temporary location
    echo "No existing app found. Performing first-time setup."
    NEW_HOSTNAME=$HOSTNAME
    NEW_APP=$APP
fi

docker build --target keycloak-package -t keycloak-package:latest ./keycloak
docker cp $(docker create keycloak-package):/tmp/keycloak/package ./keycloak

# Copy the environment helper script
cp -a ./infrastructure/env/. ./keycloak/env/
cp -a ./keycloak/env/. ./keycloak/package/env/

# Deploy the new app, set the hostname and start the app
cf push $NEW_APP -f ./keycloak/manifest.yml -d $DOMAIN --hostname $NEW_HOSTNAME

if [[ ! $APP_PREEXISTS ]]; then
    # We don't need to go any further
    exit 0
fi

# TODO smoke test or manual confirmation?

# Unmap the temporary hostname from the new app
cf unmap-route $NEW_APP $DOMAIN --hostname $NEW_HOSTNAME

# Map the live hostname to the new app
cf map-route $NEW_APP $DOMAIN --hostname $HOSTNAME

# Unmap the live hostanme from the old app
cf unmap-route $APP $DOMAIN --hostname $HOSTNAME

# Remove the old app and rename the new one
cf delete -f $APP
cf rename $NEW_APP $APP

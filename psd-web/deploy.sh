#!/usr/bin/env bash
set -ex

# This is the CI server script to deploy the site
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# SPACE: the space to which you want to deploy

DOMAIN=product-safety-database.service.gov.uk
if [[ $SPACE == "prod" ]]; then
    HOSTNAME=www
else
    HOSTNAME=$SPACE
fi
APP=psd-web
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

# Copy the environment helper script
cp -a ./infrastructure/env/. ./psd-web/env/

# Copy in the shared dependencies
rm -rf ./psd-web/vendor/shared-web/
cp -a ./shared-web/. ./psd-web/vendor/shared-web/

# Deploy the new app and set the hostname
cf push $NEW_APP -f ./psd-web/manifest.yml -d $DOMAIN --hostname $NEW_HOSTNAME --no-start
cf set-env $NEW_APP PSD_HOST "$NEW_HOSTNAME.$DOMAIN"

# Increase the assigned memory for staging
cf scale $NEW_APP -f -m 2G
cf start $NEW_APP

# Decrease the assigned memory
cf scale $NEW_APP -f -m 512M


if [[ ! $APP_PREEXISTS ]]; then
    # We don't need to go any further
    exit 0
fi

# TODO smoke test or manual confirmation?

# Unmap the temporary hostname from the new app
cf unmap-route $NEW_APP $DOMAIN --hostname $NEW_HOSTNAME

# Remove basic auth if we're deploying to production
if [[ $SPACE == "prod" ]]; then
    cf unbind-service $NEW_APP psd-auth-env
fi

# Map the live hostname to the new app
cf set-env $NEW_APP PSD_HOST "$HOSTNAME.$DOMAIN"
cf restart $NEW_APP
cf map-route $NEW_APP $DOMAIN --hostname $HOSTNAME

# Unmap the live hostanme from the old app
cf unmap-route $APP $DOMAIN --hostname $HOSTNAME

# Remove the old app and rename the new one
cf delete -f $APP
cf rename $NEW_APP $APP

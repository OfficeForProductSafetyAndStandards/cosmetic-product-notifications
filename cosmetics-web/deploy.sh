#!/usr/bin/env bash
set -ex

# This is the CI server script to deploy the site
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# SPACE: the space to which you want to deploy

DOMAIN=cosmetic-product-notifications.service.gov.uk
if [[ $SPACE == "prod" ]]; then
    SUBMIT_HOSTNAME=submit
    SEARCH_HOSTNAME=search
elif [[ $SPACE == "research" ]]; then
    DOMAIN=london.cloudapps.digital
    SUBMIT_HOSTNAME=cosmetics-research
    SEARCH_HOSTNAME=cosmetics-research
else
    SUBMIT_HOSTNAME=$SPACE-submit
    SEARCH_HOSTNAME=$SPACE-search
fi
APP=cosmetics-web
APP_PREEXISTS=$(cf app $APP && echo 0 || echo 1)

if [[ $APP_PREEXISTS ]]; then
    # We should deploy to a temporary location such that we can do a blue-green deployment
    NEW_SUBMIT_HOSTNAME=$SUBMIT_HOSTNAME-temp
    NEW_SEARCH_HOSTNAME=$SEARCH_HOSTNAME-temp
    NEW_APP=$APP-temp
else
    # We don't need to deploy to a temporary location
    echo "No existing app found. Performing first-time setup."
    NEW_SUBMIT_HOSTNAME=$SUBMIT_HOSTNAME
    NEW_SEARCH_HOSTNAME=$SEARCH_HOSTNAME
    NEW_APP=$APP
fi

# Copy the environment helper script
cp -a ./infrastructure/env/. ./cosmetics-web/env/

# Copy in the shared dependencies
rm -rf ./cosmetics-web/vendor/shared-web/
cp -a ./shared-web/. ./cosmetics-web/vendor/shared-web/

# Deploy the new app, set the hostnames and start the app
cf push $NEW_APP -f ./cosmetics-web/manifest.yml -d $DOMAIN --hostname $NEW_SUBMIT_HOSTNAME --no-start
cf set-env $NEW_APP COSMETICS_HOST "$NEW_SUBMIT_HOSTNAME.$DOMAIN"
cf map-route $NEW_APP $DOMAIN --hostname $NEW_SEARCH_HOSTNAME

# Increase the assigned memory for staging
cf scale $NEW_APP -f -m 2G
cf start $NEW_APP

# Decrease the assigned memory
cf scale $NEW_APP -f -m 512M


if [[ ! $APP_PREEXISTS ]]; then
    # We don't need to go any further
    exit 0
fi

# Run smoke tests before switching over to the new app
if [[ $SPACE != "prod" ]]; then
    echo "Running smoke tests."
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker pull beisopss/opss-functional-tests
    docker run beisopss/opss-functional-tests mvn --quiet --file ./cosmetics/pom.xml test -Dcucumber.options="--tags @smoke" \
      -Dhostname=$NEW_SUBMIT_HOSTNAME.$DOMAIN \
      -Dauth.username=${COS_BASIC_AUTH_USERNAME} -Dauth.password=${COS_BASIC_AUTH_PASSWORD} \
      -Daccount.rp.username=${RP_ACCOUNT_USERNAME} -Daccount.rp.password=${RP_ACCOUNT_PASSWORD} \
      -Daccount.npis.username=${NPIS_ACCOUNT_USERNAME} -Daccount.npis.password=${NPIS_ACCOUNT_PASSWORD}
fi
SMOKE_TEST_RESULT=$?

if [[ $SMOKE_TEST_RESULT -ne 0 ]]; then
    # Delete the temporary deployment and exit
    echo "Smoke tests failed. Aborting deployment."
    cf delete -f $NEW_APP
    exit 1
fi

# Unmap the temporary hostname(s) from the new app
cf unmap-route $NEW_APP $DOMAIN --hostname $NEW_SUBMIT_HOSTNAME
cf unmap-route $NEW_APP $DOMAIN --hostname $NEW_SEARCH_HOSTNAME

# Remove basic auth if we're deploying to production
# TODO COSBETA-240 Uncomment when service goes live
#if [[ $SPACE == "prod" ]]; then
#    cf unbind-service $NEW_APP cosmetics-auth-env
#fi

# Map the live hostnames to the new app
cf set-env $NEW_APP COSMETICS_HOST "$SUBMIT_HOSTNAME.$DOMAIN"
cf restart $NEW_APP
cf map-route $NEW_APP $DOMAIN --hostname $SUBMIT_HOSTNAME
cf map-route $NEW_APP $DOMAIN --hostname $SEARCH_HOSTNAME

# Unmap the live hostnames from the old app
cf unmap-route $APP $DOMAIN --hostname $SUBMIT_HOSTNAME
cf unmap-route $APP $DOMAIN --hostname $SEARCH_HOSTNAME

# Remove the old app and rename the new one
cf delete -f $APP
cf rename $NEW_APP $APP

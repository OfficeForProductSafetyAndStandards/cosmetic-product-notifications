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
elif [[ $SPACE == "research" ]]; then
    HOSTNAME="psd-research"
    DOMAIN=london.cloudapps.digital
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
cf scale $NEW_APP -f -m 1G


if [[ ! $APP_PREEXISTS ]]; then
    # We don't need to go any further
    exit 0
fi

# Run smoke tests before switching over to the new app
if [[ $SPACE != "prod" && $SPACE != "research" ]]; then
    echo "Running smoke tests."
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker pull beisopss/opss-functional-tests
    docker run beisopss/opss-functional-tests mvn --quiet --file ./psd/pom.xml test -Dcucumber.options="--tags @smoke" \
      -Dhostname=$NEW_HOSTNAME.$DOMAIN \
      -Dauth.username=${PSD_BASIC_AUTH_USERNAME} -Dauth.password=${PSD_BASIC_AUTH_PASSWORD} \
      -Daccount.ts.username=${TS_ACCOUNT_USERNAME} -Daccount.ts.password=${TS_ACCOUNT_PASSWORD} \
      -Daccount.opss.username=${OPSS_ACCOUNT_USERNAME} -Daccount.opss.password=${OPSS_ACCOUNT_PASSWORD}

    SMOKE_TEST_RESULT=$?

    if [[ $SMOKE_TEST_RESULT -ne 0 ]]; then
        # Delete the temporary deployment and exit
        echo "Smoke tests failed. Aborting deployment."
        cf delete -f $NEW_APP
        exit 1
    fi
fi

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

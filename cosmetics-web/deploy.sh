#!/usr/bin/env bash
set -ex

if [ -z "$SUBMIT_HOST" ]
then
  echo "Please set your submit host, eg SUBMIT_HOST=submit.cosmetic-product-notifications.service.gov.uk"
  exit
fi

if [ -z "$SEARCH_HOST" ]
then
  echo "Please set your search host, eg SEARCH_HOST=search.cosmetic-product-notifications.service.gov.uk"
  exit
fi

if [ -z "$SUPPORT_HOST" ]
then
  echo "Please set your support host, eg SUPPORT_HOST=support.cosmetic-product-notifications.service.gov.uk"
  exit
fi

MANIFEST_FILE=./cosmetics-web/manifest.yml

# Copy the environment helper script
cp -a ./infrastructure/env/. ./cosmetics-web/env/

# Set the amount of time in minutes that the CLI will wait for all instances to start.
# Because of the rolling deployment strategy, this should be set to at least the amount of
# time each app takes to start multiplied by the number of instances.
#
# See https://docs.cloudfoundry.org/devguide/deploy-apps/large-app-deploy.html
export CF_STARTUP_TIMEOUT=25

# Deploy the app and set the hostname
cf push $APP_NAME -f $MANIFEST_FILE --app-start-timeout 180 --var app-name=$APP_NAME --var submit-host=$SUBMIT_HOST --var search-host=$SEARCH_HOST --var support-host=$SUPPORT_HOST --var web-instances=$WEB_INSTANCES --var worker-instances=$WORKER_INSTANCES --var worker-max-threads=$WORKER_MAX_THREADS --var sentry-service-name=$SENTRY_SERVICE_NAME --strategy rolling

# Remove the copied infrastructure env files to clean up
rm -R cosmetics-web/env/

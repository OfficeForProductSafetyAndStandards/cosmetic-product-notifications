#!/usr/bin/env bash
set -ex

APP=$APP_NAME

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

MANIFEST_FILE=./cosmetics-web/manifest.yml


# Copy the environment helper script
cp -a ./infrastructure/env/. ./cosmetics-web/env/

# Deploy the submit app and set the hostname
cf7 push $APP -f $MANIFEST_FILE --var cosmetics-instance-name=$INSTANCE_NAME --var cosmetics-web-database=$DB_NAME --var submit-host=$SUBMIT_APP.$DOMAIN --var search-host=$SEARCH_APP.$DOMAIN --var cosmetics-host=$SUBMIT_APP.$DOMAIN --var cosmetics-redis-service=$REDIS_NAME --strategy rolling

cf7 scale $APP --process worker -i 1

# Remove the copied infrastructure env files to clean up
rm -R cosmetics-web/env/

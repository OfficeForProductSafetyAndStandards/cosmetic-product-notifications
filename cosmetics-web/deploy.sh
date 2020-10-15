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

MANIFEST_FILE=./cosmetics-web/manifest.yml


# Copy the environment helper script
cp -a ./infrastructure/env/. ./cosmetics-web/env/

# Deploy the submit app and set the hostname
cf7 push $APP_NAME -f $MANIFEST_FILE --var app-name=$APP_NAME --var submit-host=$SUBMIT_HOST --var search-host=$SEARCH_HOST --strategy rolling

cf7 scale $APP_NAME --process worker -i 1

# Remove the copied infrastructure env files to clean up
rm -R cosmetics-web/env/

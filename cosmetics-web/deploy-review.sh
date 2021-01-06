#!/usr/bin/env bash
set -ex

# Name of review app, will be defined outside
if [ -z "$REVIEW_INSTANCE_NAME" ]
then
  echo "Please set your application name, eg REVIEW_INSTANCE_NAME=ticket-123"
  exit
fi
INSTANCE_NAME=cosmetics-$REVIEW_INSTANCE_NAME

SEARCH_APP=$INSTANCE_NAME-search-web
SUBMIT_APP=$INSTANCE_NAME-submit-web

APP=$INSTANCE_NAME

DOMAIN=london.cloudapps.digital

# Please note new manifest file
MANIFEST_FILE=./cosmetics-web/manifest.review.yml

if [ -z "$DB_NAME" ]
then
  DB_NAME=cosmetics-review-database
fi
cf create-service postgres small-10 $DB_NAME -c '{"enable_extensions": ["pgcrypto"]}'

# Wait until db is prepared, might take up to 10 minutes
until cf service $DB_NAME > /tmp/db_exists && grep "create succeeded" /tmp/db_exists; do sleep 20; echo "Waiting for db"; done

if [ -z "$REDIS_NAME" ]
then
  REDIS_NAME=cosmetics-review-redis
fi
cf create-service redis tiny-3.2 $REDIS_NAME

# Wait until redis service is prepared, might take up to 10 minutes
until cf service $REDIS_NAME > /tmp/redis_exists && grep "create succeeded" /tmp/redis_exists; do sleep 20; echo "Waiting for redis"; done


# Copy files from infrastructure env
cp -a ./infrastructure/env/. ./cosmetics-web/env/

if [ -z "$WEB_MAX_THREADS" ]
then
  WEB_MAX_THREADS=5
fi

if [ -z "$WORKER_MAX_THREADS" ]
then
  WORKER_MAX_THREADS=10
fi

# Deploy the submit app and set the hostname
cf push $APP -f $MANIFEST_FILE --app-start-timeout 180 --var cosmetics-instance-name=$INSTANCE_NAME --var cosmetics-web-database=$DB_NAME --var submit-host=$SUBMIT_APP.$DOMAIN --var search-host=$SEARCH_APP.$DOMAIN --var cosmetics-host=$SUBMIT_APP.$DOMAIN --var cosmetics-redis-service=$REDIS_NAME --var sentry-current-env=$REVIEW_INSTANCE_NAME --var web-max-threads=$WEB_MAX_THREADS --var worker-max-threads=$WORKER_MAX_THREADS --strategy rolling

cf scale $APP --process worker -i 1

# Remove the copied infrastructure env files to clean up
rm -R cosmetics-web/env/

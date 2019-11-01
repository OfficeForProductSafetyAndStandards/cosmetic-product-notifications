#!/usr/bin/env bash
set -ex

# The caller should have the following environment variables set:
#
# CF_USERNAME: cloudfoundry username
# CF_PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

./infrastructure/ci/install-cf.sh
cf api api.london.cloud.service.gov.uk
cf auth
cf target -o 'beis-opss' -s $SPACE
export DB_VERSION=`cat cosmetics-web/db/schema.rb | grep 'ActiveRecord::Schema.define' | grep -o '[0-9_]\+'`
export REVIEW_INSTANCE_NAME=pr-$TRAVIS_PULL_REQUEST
export DB_NAME=cosmetics-db-$DB_VERSION
# redis will be new for each review app
export REDIS_NAME=cosmetics-review-redis-$TRAVIS_PULL_REQUEST
./$COMPONENT/deploy-review.sh
cf logout

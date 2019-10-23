#!/usr/bin/env bash
set -ex

# The caller should have the following environment variables set:
#
# CF_USERNAME: cloudfoundry username
# CF_PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

#if [[ $(./infrastructure/ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    ./infrastructure/ci/install-cf.sh
    cf login -a api.london.cloud.service.gov.uk -u $CF_USERNAME -p $CF_PASSWORD -o 'beis-opss' -s $SPACE
    export DB_VERSION=`cat cosmetics-web/db/schema.rb | grep 'ActiveRecord::Schema.define' | grep -o '[0-9_]\+'`
    export REVIEW_INSTANCE_NAME=$TRAVIS_PULL_REQUEST_BRANCH
    export DB_NAME=cosmetics-db-$DB_VERSION
    export REDIS_NAME=cosmetics-review-redis-$TRAVIS_PULL_REQUEST_BRANCH
    ./$COMPONENT/deploy-review.sh
    cf logout

    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker pull beisopss/$COMPONENT:$BUILD_ID
    docker tag beisopss/$COMPONENT:$BUILD_ID beisopss/$COMPONENT:$BRANCH
    docker push beisopss/$COMPONENT:$BRANCH
#else
    echo 'Deployment not required.'
#fi

#!/usr/bin/env bash
set -ex

# The caller should have the following environment variables set:
#
# CF_USERNAME: cloudfoundry username
# CF_PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

if [[ $(./infrastructure/ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    ./infrastructure/ci/install-cf.sh
    cf login -a api.london.cloud.service.gov.uk -u $CF_USERNAME -p $CF_PASSWORD -o 'beis-opss' -s $SPACE
    ./$COMPONENT/deploy.sh $SPACE
    cf logout

    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker pull $DOCKER_USERNAME/$COMPONENT:$BUILD_ID
    docker tag $DOCKER_USERNAME/$COMPONENT:$BUILD_ID $DOCKER_USERNAME/$COMPONENT:$BRANCH
    docker push $DOCKER_USERNAME/$COMPONENT:$BRANCH
else
    echo 'Deployment not required.'
fi

#!/usr/bin/env bash
set -ex

if [[ $(./ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    ./$COMPONENT/deploy.sh $SPACE
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker pull $DOCKER_USERNAME/$COMPONENT:$BUILD_ID
    docker tag $DOCKER_USERNAME/$COMPONENT:$BUILD_ID $DOCKER_USERNAME/$COMPONENT:$BRANCH
    docker push $DOCKER_USERNAME/$COMPONENT:$BRANCH
else
    echo 'Deployment not required.'
fi
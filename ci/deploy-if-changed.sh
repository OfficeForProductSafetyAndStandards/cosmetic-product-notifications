#!/usr/bin/env bash
set -ex

if [[ $(./ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    ./$COMPONENT/deploy.sh $SPACE
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker pull $REPOSITORY_BASE-$COMPONENT:$REPOSITORY_BASE-$COMPONENT
    docker tag $REPOSITORY_BASE-$COMPONENT:$BUILD_ID $REPOSITORY_BASE-$COMPONENT:$BRANCH
    docker push $REPOSITORY_BASE-$COMPONENT:$BRANCH
else
    echo 'Deployment not required.'
fi
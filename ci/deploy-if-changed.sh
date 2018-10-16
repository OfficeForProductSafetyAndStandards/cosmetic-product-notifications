#!/usr/bin/env bash
set -ex

if [[ $(./ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    ./$COMPONENT/deploy.sh $SPACE
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    docker pull $REPOSITORY_BASE-$COMPONENT:$REPOSITORY_BASE-$COMPONENT
    docker tag $REPOSITORY_BASE-$COMPONENT:$TRAVIS_BUILD_NUMBER $REPOSITORY_BASE-$COMPONENT:master
    docker push $REPOSITORY_BASE-$COMPONENT:master
else
    echo 'Deployment not required.'
fi
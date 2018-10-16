#!/usr/bin/env bash
# Builds Docker images for components that have changes, and then pushes all current images 
# tagged with the build ID to DockerHub.
set -ex

# Base name of the respositories for each component.
REPOSITORY_BASE=davidrendell/beis-mspsds

COMPONENTS=(
    'web'
    'worker'
    'cosmetics-web'
    'keycloak'
    'db'
    'elasticsearch'
)

echo "Logging into DockerHub"
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

for COMPONENT in "${COMPONENTS[@]}"; do
    if [[ $(./ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
        echo "Building component $COMPONENT"
        docker-compose -f docker-compose.yml -f docker-compose.ci.yml build $COMPONENT

    else
        echo "No changes for component $COMPONENT, pulling master image"
        docker pull $REPOSITORY_BASE-$COMPONENT:master
        docker tag $REPOSITORY_BASE-$COMPONENT:master $REPOSITORY_BASE-$COMPONENT:$TRAVIS_BUILD_NUMBER
    fi

    echo "Pushing image for component $COMPONENT with tag $TRAVIS_BUILD_NUMBER"
    docker push $REPOSITORY_BASE-$COMPONENT:$TRAVIS_BUILD_NUMBER
done
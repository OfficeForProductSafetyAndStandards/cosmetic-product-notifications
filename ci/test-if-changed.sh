#!/usr/bin/env bash
set -ex

if [[ $(./ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    echo "Testing component $COMPONENT"
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml pull
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml up -d
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm start_dependencies
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT \
        bin/rake db:create db:schema:load test
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml down
else
    echo 'Testing not required.'
fi

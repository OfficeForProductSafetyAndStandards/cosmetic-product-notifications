#!/usr/bin/env bash
set -ex

if [[ $(./infrastructure/ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    echo "Testing component $COMPONENT"
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml pull
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm --no-deps $COMPONENT echo 'Gems pre-installed'
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml up -d $COMPONENT
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm start_dependencies
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT \
        bin/rake db:create db:schema:load db:seed test:all
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml down
else
    echo 'Testing not required.'
fi

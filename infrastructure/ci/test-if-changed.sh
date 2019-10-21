#!/usr/bin/env bash
set -ex

docker-compose -f docker-compose.yml -f docker-compose.ci.yml pull db elasticsearch redis keycloak maintenance cosmetics-web cosmetics-worker
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm --no-deps $COMPONENT echo 'Gems pre-installed'
docker-compose -f docker-compose.yml -f docker-compose.ci.yml up -d $COMPONENT

if [[ $(./infrastructure/ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    echo "Testing component $COMPONENT"
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm start_dependencies
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT bin/rake db:create db:schema:load test:all
else
    echo 'Testing not required.'
fi

docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT bin/rake submit_coverage
docker-compose -f docker-compose.yml -f docker-compose.ci.yml down

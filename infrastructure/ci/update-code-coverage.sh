#!/usr/bin/env bash
set -ex

docker-compose -f docker-compose.yml -f docker-compose.ci.yml pull
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm --no-deps $COMPONENT echo "Gems pre-installed"
docker-compose -f docker-compose.yml -f docker-compose.ci.yml up -d $COMPONENT
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm start_dependencies

set +e # Disable exit if test execution fails

echo "Generating code coverage for $COMPONENT"
docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT bin/rake db:create db:schema:load test:all

set -e # Exit if any subsequent command fails

echo "Submitting code coverage report"
docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT bin/rake submit_coverage
docker-compose -f docker-compose.yml -f docker-compose.ci.yml down

#!/usr/bin/env bash
set -ex

docker-compose -f docker-compose.yml -f docker-compose.ci.yml pull
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm --no-deps cosmetics-web echo "Gems pre-installed"
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm --no-deps psd-web echo "Gems pre-installed"
docker-compose -f docker-compose.yml -f docker-compose.ci.yml up -d
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm start_dependencies

set +e # Disable exit if test execution fails

echo "Generating code coverage for cosmetics-web"
docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec cosmetics-web bin/rake db:create db:schema:load test:all
echo "Generating code coverage for psd-web"
docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec psd-web bin/rake db:create db:schema:load test:all

set -e # Exit if any subsequent command fails

echo "Submitting code coverage reports"
docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec cosmetics-web bin/rake submit_coverage
docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec psd-web bin/rake submit_coverage
docker-compose -f docker-compose.yml -f docker-compose.ci.yml down

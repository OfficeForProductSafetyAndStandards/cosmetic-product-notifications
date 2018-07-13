#!/bin/bash
set -ex

docker-compose -f docker-compose.yml -f docker-compose.ci.yml build

# Use bundler to stop spring checking the DB before it's ready
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run web rake db:create
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run web rake db:schema:load
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run web rake test

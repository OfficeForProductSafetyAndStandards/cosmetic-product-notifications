#!/bin/bash
set -ex

docker-compose build
# Use bundler to stop spring checking the DB before it's ready
docker-compose run web bundle exec rake db:create
docker-compose run web bundle exec rake db:schema:load
docker-compose run web rails test
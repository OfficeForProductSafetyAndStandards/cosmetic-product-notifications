#!/bin/bash
set -ex

docker-compose build
# Use bundler to stop spring checking the DB before it's ready
docker-compose run web bin/bundle exec rake db:create:all --trace
docker-compose run web bin/rake db:schema:load
docker-compose run web rails test
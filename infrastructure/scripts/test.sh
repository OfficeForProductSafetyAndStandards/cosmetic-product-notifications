#!/bin/bash
set -ex

docker-compose build
docker-compose run web RAILS_ENV=test rake db:create && bin/rails test
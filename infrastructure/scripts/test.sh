#!/bin/bash
set -ex

docker-compose build
docker-compose run web rake db:create && bin/rails test
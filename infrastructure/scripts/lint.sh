#!/bin/bash
set -ex

docker-compose build
docker-compose run web rubocop
#!/bin/bash
set -ex

docker-compose -f docker-compose.yml -f docker-compose.ci.yml build

docker-compose -f docker-compose.yml -f docker-compose.ci.yml run web rubocop

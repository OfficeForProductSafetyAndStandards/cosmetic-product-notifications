#!/bin/bash
set -ex

# This is the CI server script to deploy the site
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# USERNAME: cloudfoundry username
# PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

[[ -v SPACE ]] || read -p "Which space? (int,staging,live): " SPACE
case $SPACE in
  int | staging )
    HOSTNAME=mspsds-$SPACE
  ;;
  live )
    HOSTNAME=mspsds
  ;;
  * )
    echo "Bad space value"
    exit 1
  ;;
esac

./infrastructure/scripts/install-cf.sh

cf login -a api.cloud.service.gov.uk -u $USERNAME -p $PASSWORD -o "beis-mspsds" -s $SPACE

# v3-push is in an experimental stage so could break
cf v3-push $HOSTNAME \
  -b https://github.com/cloudfoundry/apt-buildpack.git \
  -b nodejs_buildpack \
  -b ruby_buildpack
# Run the migrations
cf run-task $HOSTNAME "bundle exec rake db:migrate" --name migrate-db

cf logout

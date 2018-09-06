#!/bin/bash
set -ex

# This is the CI server script to deploy the sidekiq worker
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# USERNAME: cloudfoundry username
# PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

./shared/install-cf.sh

cf login -a api.cloud.service.gov.uk -u $USERNAME -p $PASSWORD -o "beis-mspsds" -s $SPACE

# Circumvent the cloudfoundry asset compilation step - https://github.com/cloudfoundry/ruby-buildpack/blob/master/src/ruby/finalize/finalize.go#L213
cp -a ./sidekiq/public/. ./public/

# Copy the apt packages to be installed
cp ./sidekiq/apt.yml ./apt.yml

# Copy the clamav configuration
cp -a ./sidekiq/clamav/. ./clamav/

cf push -f ./sidekiq/manifest.yml

cf logout

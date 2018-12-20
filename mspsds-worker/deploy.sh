#!/usr/bin/env bash
set -ex

# This is the CI server script to deploy the sidekiq worker
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# SPACE: the space to which you want to deploy
# If NO_START is set the app won't be started

# Circumvent the cloudfoundry asset compilation step - https://github.com/cloudfoundry/ruby-buildpack/blob/master/src/ruby/finalize/finalize.go#L213
cp -a ./shared-worker/public/. ./mspsds-web/public/

# Copy the apt packages to be installed
cp ./shared-worker/apt.yml ./mspsds-web/apt.yml

# Copy the clamav configuration
cp -a ./shared-worker/clamav/. ./mspsds-web/clamav/

rm -rf ./mspsds-web/vendor/shared-web/
cp -a ./shared-web/. ./mspsds-web/vendor/shared-web/

if [[ -z ${NO_START} ]] ; then
    cf push -f ./mspsds-worker/manifest.yml
fi
if [[ ${NO_START} ]] ; then
    cf push -f ./mspsds-worker/manifest.yml --no-start
fi

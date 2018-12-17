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
cp -a ./worker/public/. ./web/public/

# Copy the apt packages to be installed
cp ./worker/apt.yml ./web/apt.yml

# Copy the clamav configuration
cp -a ./worker/clamav/. ./web/clamav/

rm -fr ./web/vendor/shared-web/
cp -a ./shared-web/. ./web/vendor/shared-web/

if [[ -z ${NO_START} ]] ; then
    cf push -f ./worker/manifest.yml
fi
if [[ ${NO_START} ]] ; then
    cf push -f ./worker/manifest.yml --no-start
fi

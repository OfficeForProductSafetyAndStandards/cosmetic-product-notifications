#!/usr/bin/env bash
set -ex

# This is the CI server script to deploy the site
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# SPACE: the space to which you want to deploy
# If NO_START is set the app won't be started

rm -rf ./mspsds-web/vendor/shared-web/
cp -a ./shared-web/. ./mspsds-web/vendor/shared-web/

cf push -f ./mspsds-web/manifest.yml --hostname mspsds-$SPACE $( [[ ${NO_START} ]] && printf %s '--no-start' )

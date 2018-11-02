#!/usr/bin/env bash
set -ex

# This is the CI server script to deploy the site
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# CF_USERNAME: cloudfoundry username
# CF_PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

cp ./shared-web ./cosmetics-web/vendor/shared-web 

./ci/install-cf.sh

cf login -a api.cloud.service.gov.uk -u $CF_USERNAME -p $CF_PASSWORD -o 'beis-mspsds' -s $SPACE

cf push -f ./cosmetics-web/manifest.yml --hostname cosmetics-$SPACE

cf logout

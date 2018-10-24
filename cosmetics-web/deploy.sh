#!/usr/bin/env bash
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

./ci/install-cf.sh

cf login -a api.cloud.service.gov.uk -u $USERNAME -p $PASSWORD -o 'beis-mspsds' -s $SPACE

cf push -f ./web/manifest.yml --route-path cosmetics-$SPACE

cf logout

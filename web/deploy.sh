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
#
# If SET_UP is set the script will omit installing cf cli and logging in and out
# This can be used to invoke the script from dev machines when performing initial setup

cp -a ./shared-web/. ./web/vendor/shared-web/

if [[ -z ${SET_UP} ]] ; then
    ./ci/install-cf.sh
    cf login -a api.london.cloud.service.gov.uk -u $CF_USERNAME -p $CF_PASSWORD -o 'beis-mspsds' -s $SPACE
    cf push -f ./web/manifest.yml --hostname mspsds-$SPACE
    cf logout
fi
if [[ ${SET_UP} ]] ; then
    cf push -f ./web/manifest.yml --hostname mspsds-$SPACE --no-start
fi

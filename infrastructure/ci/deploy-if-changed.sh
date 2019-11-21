#!/usr/bin/env bash
set -ex

# The caller should have the following environment variables set:
#
# CF_USERNAME: cloudfoundry username
# CF_PASSWORD: cloudfoundry password
# SPACE: the space to which you want to deploy

if [[ $(./infrastructure/ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    ./infrastructure/ci/install-cf.sh
    cf api api.london.cloud.service.gov.uk
    cf auth
    cf target -o 'beis-opss' -s $SPACE
    ./$COMPONENT/deploy.sh
    cf logout

else
    echo 'Deployment not required.'
fi

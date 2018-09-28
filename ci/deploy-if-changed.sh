#!/usr/bin/env bash
set -ex

if [[ $(./ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    ./$COMPONENT/deploy.sh $SPACE
else
    echo 'Deployment not required.'
fi
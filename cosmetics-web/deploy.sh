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

DOMAIN=london.cloudapps.digital
HOSTNAME=cosmetics-$SPACE
COMPONENT=cosmetics-web

cf app $COMPONENT || APP_DOES_NOT_EXIST="true"

rm -rf ./$COMPONENT/vendor/shared-web/
cp -a ./shared-web/. ./$COMPONENT/vendor/shared-web/

if [[ ! $APP_DOES_NOT_EXIST ]]; then
    # Route to the maintenance page
    cf map-route maintenance $DOMAIN --hostname $HOSTNAME
    cf unmap-route $COMPONENT $DOMAIN --hostname $HOSTNAME
fi

cf push -f ./$COMPONENT/manifest.yml $( [[ $APP_DOES_NOT_EXIST ]] && printf %s "--hostname $HOSTNAME" || printf %s "--no-route" ) $( [[ $NO_START ]] && printf %s "--no-start" )

if [[ ! $APP_DOES_NOT_EXIST ]]; then
    # Route to newly deployed app
    cf map-route $COMPONENT $DOMAIN --hostname $HOSTNAME
    cf unmap-route maintenance $DOMAIN --hostname $HOSTNAME
fi

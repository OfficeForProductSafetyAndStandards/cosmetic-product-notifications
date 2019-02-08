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

if cf app cosmetics-web; then
    # We've deployed this app before, get the URL
    URL=`cf app cosmetics-web | grep routes | awk {'print $2'}`
    HOSTNAME=`echo $URL | cut -d'.' -f 1`
    DOMAIN=`echo $URL | cut -d'.' -f 2-`
else 
    # We haven't deployed this app before
    HOSTNAME=cosmetics-$SPACE
fi

rm -rf ./cosmetics-web/vendor/shared-web/
cp -a ./shared-web/. ./cosmetics-web/vendor/shared-web/

if [[ $DOMAIN ]]; then
    # Route to the maintenance page
    cf map-route maintenance $DOMAIN --hostname $HOSTNAME
    cf unmap-route cosmetics-web $DOMAIN --hostname $HOSTNAME
fi

cf push -f ./cosmetics-web/manifest.yml $( [[ ! $DOMAIN ]] && printf %s "--hostname $HOSTNAME") $( [[ ${NO_START} ]] && printf %s "--no-start" )

if [[ $DOMAIN ]]; then
    # Route to newly deployed app
    cf map-route cosmetics-web $DOMAIN --hostname $HOSTNAME
    cf unmap-route maintenance $DOMAIN --hostname $HOSTNAME
fi

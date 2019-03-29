#!/usr/bin/env bash
set -ex

# This is the CI server script to deploy the sidekiq worker
#
# The working directory should be the git root
#
# The caller should have the following environment variables set:
#
# SPACE: the space to which you want to deploy

APP=cosmetics-worker
APP_PREEXISTS=$(cf app $APP && echo 0 || echo 1)

if [[ ! $APP_PREEXISTS ]]; then
    echo "No existing app found. Performing first-time setup."
fi

# Copy the environment helper script
cp -a ./infrastructure/env/. ./cosmetics-web/env/

# Circumvent the cloudfoundry asset compilation step - https://github.com/cloudfoundry/ruby-buildpack/blob/master/src/ruby/finalize/finalize.go#L213
mkdir -p ./cosmetics-web/public/assets
touch ./cosmetics-web/public/assets/.sprockets-manifest-qq.json

rm -rf ./cosmetics-web/vendor/shared-web/
cp -a ./shared-web ./cosmetics-web/vendor/shared-web

cf push -f ./cosmetics-worker/manifest.yml $( [[ ! ${APP_PREEXISTS} ]] && printf %s '--no-start' )

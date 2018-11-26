#!/usr/bin/env bash
set -ex
bundle update
# Ensure all gems are installed.
bin/bundle check || bin/bundle install

# Ensure the correct directory for development is used for importing shared-web with yarn
yarn add ./vendor/shared-web

# Ensure all node packages are installed.
yarn install

# Setup display for system tests
SCREEN="${SCREEN:-1280x1024x16}"
echo "Starting X virtual framebuffer (Xvfb) for $SCREEN screen in background..."
Xvfb -ac :99 -screen 0 $SCREEN > /dev/null 2>&1 &
export DISPLAY=:99

# Run the passed in command
exec "$@"

#!/usr/bin/env bash
set -ex

# Ensure all gems are installed.
bin/bundle check || bin/bundle install

# Ensure all node packages are installed.
yarn install

# Setup display for system tests
SCREEN="${SCREEN:-1280x1024x16}"
echo "Starting X virtual framebuffer (Xvfb) for $SCREEN screen in background..."
Xvfb -ac :99 -screen 0 $SCREEN > /dev/null 2>&1 &
export DISPLAY=:99

bin/webpack-dev-server --progress &

# Run the passed in command
exec "$@"

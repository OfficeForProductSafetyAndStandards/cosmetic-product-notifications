#!/usr/bin/env bash
set -ex

# Ensure all gems are installed.
bin/bundle check || bin/bundle install

# Ensure all node packages are installed.
yarn install

# Run the passed in command
exec "$@"

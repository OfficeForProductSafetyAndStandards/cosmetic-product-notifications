#!/usr/bin/env bash
set -ex

# Ensure all gems are installed.
bin/bundle check || bin/bundle install

# Ensure all node packages are installed.
yarn install

# freshclam returns code 1 when it's up-to-date...
freshclam || EXIT_CODE=$?
if [[ $EXIT_CODE > 1 ]]; then
    exit $EXIT_CODE
fi
service clamav-daemon start

# Run the passed in command
exec "$@"

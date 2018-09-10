#!/bin/bash
set -ex

# Ensure all gems are installed.
bin/bundle check || bin/bundle install

freshclam
service clamav-daemon start

# Run the passed in command
exec "$@"

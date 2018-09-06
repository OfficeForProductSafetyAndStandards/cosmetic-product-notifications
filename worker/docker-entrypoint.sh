#!/bin/bash
set -ex

# Ensure all gems are installed.
bin/bundle check || bin/bundle install

service clamav-daemon start

# Run the passed in command
exec "$@"

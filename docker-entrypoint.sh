#!/bin/bash
set -ex

# Ensure all gems are installed.
bundle check || bundle install

# Ensure all node packages are installed.
bin/yarn install

# Run the passed in command
exec "$@"

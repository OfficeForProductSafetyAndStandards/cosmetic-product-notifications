#!/bin/bash
set -ex

# Ensure all gems are installed.
bundle check || bundle install

# Ensure all node pacages are installed.
npm install

# Run the passed in command
exec "$@"

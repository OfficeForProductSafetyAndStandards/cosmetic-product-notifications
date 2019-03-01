#!/usr/bin/env bash
set -ex

# Ensure all gems are installed.
bundle check || bundle install

# Start clamav
freshclam -d &
clamd &

ruby server.rb

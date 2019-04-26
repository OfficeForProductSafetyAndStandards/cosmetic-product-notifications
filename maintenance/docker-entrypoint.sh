#!/usr/bin/env bash
set -ex

# Ensure all node packages are installed.
yarn install

# Launch the server
yarn start

#!/usr/bin/env bash
set -ex

# This is the CI server script to deploy the maintenance page
#
# The working directory should be the git root

cf push -f ./maintenance/manifest.yml

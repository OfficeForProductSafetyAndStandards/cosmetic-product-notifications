#!/usr/bin/env bash
set -ex

# This is the CI server script to deploy the antivirus API
#
# The working directory should be the git root

cf push

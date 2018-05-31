#!/usr/bin/env bash
set -ex

# This is the CI server script to install the Cloud Foundry CLI

wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key |
sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
sudo apt-get -qq update
sudo apt-get install cf-cli

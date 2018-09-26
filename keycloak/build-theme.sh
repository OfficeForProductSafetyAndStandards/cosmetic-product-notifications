#!/bin/bash
set -ex

# This script builds the GOV.UK Keycloak theme
#
# The working directory should be the git root

THEME_PATH=./keycloak/govuk-theme
PACKAGE_PATH=./keycloak/package

# Download and add the GOV.UK theme
cd $THEME_PATH
npm install
npm run build
cd ../../

mkdir -p $PACKAGE_PATH/themes

cp -r $THEME_PATH/govuk $PACKAGE_PATH/themes/
cp -r $THEME_PATH/govuk-internal $PACKAGE_PATH/themes/
cp -r $THEME_PATH/govuk-social-providers $PACKAGE_PATH/themes/

#!/bin/bash
set -ex

# This script builds and adds the GOV.UK Notify email service provider
#
# The working directory should be the git root

PROVIDER_PATH=./keycloak/providers
PACKAGE_PATH=./keycloak/package

# Build and add the GOV.UK Notify email service provider
mkdir -p $PACKAGE_PATH/providers
mvn -q --settings $PROVIDER_PATH/settings.xml --file $PROVIDER_PATH/pom.xml package
cp $PROVIDER_PATH/target/notify-email-provider-jar-with-dependencies.jar $PACKAGE_PATH/providers

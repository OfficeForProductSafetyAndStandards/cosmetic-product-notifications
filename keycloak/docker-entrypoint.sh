#!/bin/bash

###########################
# Import realms and users #
###########################
SYS_PROPS="-Dkeycloak.migration.action=import \
  -Dkeycloak.migration.provider=singleFile \
  -Dkeycloak.migration.strategy=IGNORE_EXISTING \
  -Dkeycloak.migration.file=/tmp/keycloak/initial-setup.json"

##################
# Start Keycloak #
##################

exec /opt/jboss/keycloak/bin/standalone.sh ${SYS_PROPS} $@
exit $?

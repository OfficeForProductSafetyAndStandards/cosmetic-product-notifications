#!/bin/bash

##################
# Add admin user #
##################

if [ ${KEYCLOAK_USER} ] && [ ${KEYCLOAK_PASSWORD} ]; then
  /opt/jboss/keycloak/bin/add-user-keycloak.sh --user ${KEYCLOAK_USER} --password ${KEYCLOAK_PASSWORD}
fi

##################
# Start Keycloak #
##################

exec /opt/jboss/keycloak/bin/standalone.sh ${SYS_PROPS} $@
exit $?

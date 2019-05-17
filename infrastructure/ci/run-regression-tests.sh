#!/usr/bin/env bash
set -ex

# The caller should have the following environment variables set:
#
# DOCKER_USERNAME: DockerHub username
# DOCKER_PASSWORD: DockerHub password
# SERVICE: the service to be tested (psd|cosmetics)
# SERVICE_HOSTNAME: hostname to be tested

echo "Running ${SERVICE} regression tests."
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
docker pull beisopss/opss-functional-tests
docker run beisopss/opss-functional-tests mvn --quiet --file ./${SERVICE}/pom.xml test -Dcucumber.options="--tags @smoke" \
  -Dhostname=${SERVICE_HOSTNAME} -Dauth.username=${BASIC_AUTH_USERNAME} -Dauth.password=${BASIC_AUTH_PASSWORD} \
  -Daccount.opss.username=${OPSS_ACCOUNT_USERNAME} -Daccount.opss.password=${OPSS_ACCOUNT_PASSWORD} \
  -Daccount.npis.username=${NPIS_ACCOUNT_USERNAME} -Daccount.npis.password=${NPIS_ACCOUNT_PASSWORD} \
  -Daccount.rp.username=${RP_ACCOUNT_USERNAME} -Daccount.rp.password=${RP_ACCOUNT_PASSWORD} \
  -Daccount.ts.username=${TS_ACCOUNT_USERNAME} -Daccount.ts.password=${TS_ACCOUNT_PASSWORD} \

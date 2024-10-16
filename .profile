# See: https://docs.cloudfoundry.org/devguide/deploy-apps/deploy-app.html#profile
#   Extracts and exports Rails config from VCAP_SERVICES
export $(./env/get-env-from-vcap.sh)

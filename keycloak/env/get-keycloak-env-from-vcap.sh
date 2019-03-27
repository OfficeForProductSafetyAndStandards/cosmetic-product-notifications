if [[ ! $VCAP_SERVICES ]]; then
    >&2 echo "\$VCAP_SERVICES not found"
    exit 1
fi

./env/get-env-from-vcap.sh

echo "KEYCLOAK_DATABASE=$(echo $VCAP_SERVICES | ./env/jq -r '.postgres[] | select(.name == "keycloak-database") .credentials .name')"
echo "KEYCLOAK_DATABASE_HOSTNAME=$(echo $VCAP_SERVICES | ./env/jq -r '.postgres[] | select(.name == "keycloak-database") .credentials .host')"
echo "KEYCLOAK_DATABASE_PASSWORD=$(echo $VCAP_SERVICES | ./env/jq -r '.postgres[] | select(.name == "keycloak-database") .credentials .password')"
echo "KEYCLOAK_DATABASE_USERNAME=$(echo $VCAP_SERVICES | ./env/jq -r '.postgres[] | select(.name == "keycloak-database") .credentials .username')"

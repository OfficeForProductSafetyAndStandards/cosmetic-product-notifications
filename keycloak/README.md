# Keycloak Auth Service

This folder contains the configuration and code for the Keycloak service.


## Overview

We are using a customised version of the [Keycloak](https://www.keycloak.org/index.html) standalone server
for user identity and access management (IdAM).

We're using the [GOV.UK theme](https://github.com/UKHomeOffice/keycloak-theme-govuk) for Keycloak
maintained by the Home Office.


## Getting Setup

This assumes you've followed the setup steps in [the root README](../README.md#getting-setup).

Visit the Keycloak admin console on [http://keycloak:8080/auth/admin](http://keycloak:8080/auth/admin)
(default credentials can be found [here](../README.md#accounts))


Note that the addition of a "keycloak" entry to the hosts file (as described in the [the root README](../README.md#getting-setup))
is needed because the website Docker container and host browser need to access Keycloak on the same hostname
(due to the requirement that access tokens must be issued and validated on the same hostname).


## Deployment

Keycloak is manually deployed by running the `./keycloak/deploy.sh` script from the root directory.


### Deployment from scratch

Login to GOV.UK PaaS and set the relevant space as described in [the root README](../README.md#deployment-from-scratch).

To create a Keycloak database for the current space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    cf create-service postgres tiny-unencrypted-9.5 keycloak-database

Running the following commands from the root directory will then package and set up the Keycloak app:

    ./keycloak/package.sh
    cf push -f ./keycloak/manifest.yml --no-start

Once the app has been created, add the following environment variables to specify the database connection properties:

    cf set-env keycloak KEYCLOAK_DATABASE          << see: VCAP_SERVICES.postgres.credentials.name >>
    cf set-env keycloak KEYCLOAK_DATABASE_HOSTNAME << see: VCAP_SERVICES.postgres.credentials.host >>
    cf set-env keycloak KEYCLOAK_DATABASE_USERNAME << see: VCAP_SERVICES.postgres.credentials.username >>
    cf set-env keycloak KEYCLOAK_DATABASE_PASSWORD << see: VCAP_SERVICES.postgres.credentials.password >>
    cf restage keycloak

(The relevant values are specified as properties on the `VCAP_SERVICES` environment variable,
 which can be listed by running `cf env keycloak`)


### Initial configuration

_**(This should be replaced by an initial import script run as part of the deployment.)**_

Once Keycloak is running, connect via an SSH tunnel to access the admin console and create the initial admin user:

    cf ssh keycloak -N -L 8080:localhost:8080

Then point your browser to [http://localhost:8080/auth](http://localhost:8080/auth) and follow the instructions.

Create the MSPSDS realm:
* Select realm > Add realm > Import > Select file: `keycloak/initial-setup.json`

Generate a new client secret for the MSPSDS app:
* Select realm > MSPSDS > Clients > mspsds-app > Credentials > Regenerate Secret

Set the client credentials for the MSPSDS app:

    cf set-env mspsds-web KEYCLOAK_AUTH_URL https://keycloak-<<SPACE>>.cloudapps.digital/auth
    cf set-env mspsds-web KEYCLOAK_CLIENT_ID mspsds-app
    cf set-env mspsds-web KEYCLOAK_CLIENT_SECRET <<SECRET>>
    cf restage mspsds-web

(The client secret is listed on the Keycloak admin console: Clients > mspsds-app > Credentials)

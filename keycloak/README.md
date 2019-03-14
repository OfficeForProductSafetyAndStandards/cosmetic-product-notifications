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

Keycloak is automatically deployed to the relevant environment by Travis CI, as described in
[the root README](../README.md#deployment).


### Deployment from scratch

Login to GOV.UK PaaS and set the relevant space as described in [the root README](../README.md#deployment-from-scratch).


#### Database

To create a Keycloak database for the current space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    cf create-service postgres small-10.5 keycloak-database


#### Keycloak

Running the following commands from the root directory will then package and set up the Keycloak app:

    NO_START=true SPACE=<<SPACE>> ./keycloak/deploy.sh

Once the app has been created, add the following environment variables to specify the database connection properties:

    cf set-env keycloak KEYCLOAK_DATABASE          << see: VCAP_SERVICES.postgres.credentials.name >>
    cf set-env keycloak KEYCLOAK_DATABASE_HOSTNAME << see: VCAP_SERVICES.postgres.credentials.host >>
    cf set-env keycloak KEYCLOAK_DATABASE_USERNAME << see: VCAP_SERVICES.postgres.credentials.username >>
    cf set-env keycloak KEYCLOAK_DATABASE_PASSWORD << see: VCAP_SERVICES.postgres.credentials.password >>

The relevant values are specified as properties on the `VCAP_SERVICES` environment variable, which can be listed by
running `cf env keycloak`. 

    cf set-env keycloak NOTIFY_API_KEY             XXX
    
See the GOV.UK Notify account section in [the root README](../README.md#gov.uk-notify) to get the API key.

    cf set-env keycloak NOTIFY_SMS_TEMPLATE_ID     XXX

with the value coming from [gov.uk Notify](https://www.notifications.service.gov.uk/services/)
(see Notify accounts section in the [root README](../README.md#GOV.UK Notify))

Finally, start the app and check that it is running correctly:

    cf start keycloak
    cf logs keycloak --recent

### Initial configuration

When deploying Keycloak from scratch, an initial configuration file is imported on first launch, which creates a
default admin user for the master realm, creates and configures the MSPSDS realm and associated client, and creates
a default test user account for logging into the MSPSDS website.

The relevant login credentials can be found in the accounts section of [the root README](../README.md#keycloak).

**IMPORTANT:** *You should follow the instructions below to change the admin password and client secret from their
default values.*

Log into the Keycloak administration console using the default admin credentials.

Set a strong password for the master admin account:
* Select realm > Master > Users > View all users
* Edit the admin user > Credentials
* Enter and confirm the new password, disable the 'Temporary' option, and click 'Reset Password'

#### Setup clients
*The instructions in this sections are given for the mspsds client, but should be repeated for all clients required.*

Generate a new client secret for the MSPSDS app:
* Select realm > OPSS > Clients > mspsds-app > Credentials > Regenerate Secret

Create the client credentials for the MSPSDS app:

    cf cups mspsds-auth-env -p '{
        "KEYCLOAK_AUTH_URL": "https://keycloak-<<SPACE>>.london.cloudapps.digital/auth",
        "KEYCLOAK_CLIENT_ID": "mspsds-app",
        "KEYCLOAK_CLIENT_SECRET": "XXX"
    }'

(The client secret is listed on the Keycloak admin console: Clients > mspsds-app > Credentials)

Allow keycloak to redirect back to the app after login
* Select realm > OPSS > Clients > mspsds-app
* Add `https://mspsds-<<SPACE>>.london.cloudapps.digital/*` to the Valid Redirect URIs section and click save
* Replace all `localhost` values with `https://mspsds-<<SPACE>>.london.cloudapps.digital/`

Follow the steps in [the SMS autheticator README's Configuration section](
https://github.com/UKGovernmentBEIS/keycloak-sms-authenticator-sns/blob/develop/README.md#Configuration) 
to enable SMS two factor authentication. Set the 2FA code length to 6.

### Setup event logging
Setup the system out event listener:
* Select Events > Config
* Add "system-out" to the "Event Listeners" section


### Troubleshooting
##### Problem: the keycloak database doesn't exist when running `$ docker-compose up`
Error message:
```
WARN  [org.jboss.jca.core.connectionmanager.pool.strategy.OnePool] (ServerService Thread Pool -- 52) IJ000604: Throwable while attempting to get a new connection: null: javax.resource.ResourceException: IJ031084: Unable to create connection
[......]
Caused by: org.postgresql.util.PSQLException: FATAL: database "keycloak" does not exist
```

The first time `$ docker-compose up` is run in the root directory, a keycloak database is created according to 
`/postgres/setup-keycloak.sh`. This database shares a docker volume with the dev database.

If the local keycloak database is subsequently dropped but the development database is not, then this script will not 
run the next time you run `$ docker-compose up`.

To recreate the database, start the postgres command line with

```$ docker-compose exec postgres --username keycloak```

then in the postgres interface run each command from `/postgres/setup-keycloak.sh`.

# Deploying the site from scratch

This document records the steps that are necessary
to deploy the site(s) to the GOV.UK cloud PaaS.

These instructions are kept for future reference.

## Common tasks

Get a GOV.UK account.

Install the `cf` CLI from https://github.com/cloudfoundry/cli#downloads

    cf login -a api.cloud.service.gov.uk -u XXX -p XXX
    cf target -o beis-mspsds
    cf create-space int
    cf target -o "beis-mspsds" -s "int"

## Database

Create a blank database in the `int` space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    # Consider larger DBs for other environments
    cf create-service postgres tiny-unencrypted-9.5 mspsds-database

## Rails Site

Create the app using the current repository

    cf push
    # Add the "RAILS_ENV" variable to tell rails to use the prod database
    cf set-env mspsds-int RAILS_ENV production
    # Add a username and password for the HTTP authentication
    cf set-env mspsds-int USERNAME XXX
    cf set-env mspsds-int PASSWORD XXX
    # Add API key created in Notify
    cf set-env mspsds-int NOTIFY_API_KEY XXX
    # Add host for email links
    cf set-env mspsds-int MSPSDS_HOST "mspsds-int.cloudapps.digital"
    # Seed the DB with an admin
    cf set-env mspsds-int ADMIN_EMAIL "john@example.com"
    cf set-env mspsds-int ADMIN_PASSWORD XXX
    cf restage mspsds-int

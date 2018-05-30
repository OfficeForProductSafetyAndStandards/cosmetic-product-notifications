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
    cf create-service postgres Free mspsds-database # Consider larger DBs for other environments

## Rails Site

Add the "RAILS_ENV" variable to tell rails to use the prod database

    cf push
    cf set-env mspsds-int RAILS_ENV production
    cf restage mspsds-int

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

Create an AWS user called int-mspsds keep a note of the Access key ID and secret access key.
Give this user the AmazonS3FullAccess policy.


## Database

Create a blank database in the `int` space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    # Consider larger DBs for other environments
    cf create-service postgres tiny-unencrypted-9.5 mspsds-database

## S3

Create an S3 bucket named `int-mspsds`. This bucket needs public _read_ access.

## Elastic Search

Create an empty elasticsearch instance in the `int` space

    cf marketplace -s elasticsearch
    cf create-service elasticsearch small-ha-6.x mspsds-elasticsearch

## Redis

Create an empty redis instance in the `int` space. Sidekiq will only work with the unclustered version

    cf marketplace -s redis
    cf create-service redis tiny-unclustered-3.2 mspsds-redis

## Rails Site

Create the app using the current repository

    cf push --no-start
    # Add the "RAILS_ENV" variable to tell rails to use the prod database
    cf set-env mspsds-int RAILS_ENV production

    # Add a username and password for the HTTP authentication
    cf set-env mspsds-int USERNAME XXX
    cf set-env mspsds-int PASSWORD XXX

    # Add AWS info
    cf set-env mspsds-int AWS_ACCESS_KEY_ID XXX
    cf set-env mspsds-int AWS_SECRET_ACCESS_KEY XXX
    cf set-env mspsds-int AWS_REGION XXX
    cf set-env mspsds-int AWS_S3_BUCKET XXX


    # Add API key created in Notify
    cf set-env mspsds-int NOTIFY_API_KEY XXX
    # Add API key created in Companies house
    cf set-env mspsds-int COMPANIES_HOUSE_API_KEY XXX

    # Add host for email links
    cf set-env mspsds-int MSPSDS_HOST "mspsds-int.cloudapps.digital"

    # Seed the DB with an admin
    cf set-env mspsds-int ADMIN_EMAIL "john@example.com"
    cf set-env mspsds-int ADMIN_PASSWORD XXX

    # Repeat a subset for mspsds-sidekiq
    cf push -f sidekiq-manifest.yml --no-start
    cf set-env mspsds-sidekiq RAILS_ENV production
    cf set-env mspsds-sidekiq AWS_ACCESS_KEY_ID XXX
    cf set-env mspsds-sidekiq AWS_SECRET_ACCESS_KEY XXX
    cf set-env mspsds-sidekiq AWS_REGION XXX
    cf set-env mspsds-sidekiq AWS_S3_BUCKET XXX
    cf set-env mspsds-sidekiq NOTIFY_API_KEY XXX
    cf set-env mspsds-sidekiq COMPANIES_HOUSE_API_KEY XXX
    cf set-env mspsds-sidekiq MSPSDS_HOST "mspsds-int.cloudapps.digital"

Trigger the deploy scripts on travis.
Then seed the database

    cf run-task mspsds-int "bundle exec rake db:seed" --name seed-db

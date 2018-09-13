# Market Surveillance & Product Safety Digital Service

[![Build Status](https://travis-ci.org/UKGovernmentBEIS/beis-mspsds.svg?branch=master)](https://travis-ci.org/UKGovernmentBEIS/beis-mspsds)
[![Coverage Status](https://coveralls.io/repos/github/UKGovernmentBEIS/beis-mspsds/badge.svg?branch=master)](https://coveralls.io/github/UKGovernmentBEIS/beis-mspsds?branch=master)


## Getting Setup

Install Docker: https://docs.docker.com/install/.

Increase the memory available to Docker to at least 4GB (instructions for [Mac](https://docs.docker.com/docker-for-mac/#advanced), [Windows](https://docs.docker.com/docker-for-windows/#advanced)).

Copy the file in the root of the directory called `.env-template`.
Rename the copy of the file to `.env` and fill in any environment variables.
This `.env` file will be git ignored, so it is safe to add sensitive data.
See the [accounts section](#accounts) below for information on how to obtain some of the optional variables.

Add the following entry for Keycloak to your hosts file ([instructions](https://support.rackspace.com/how-to/modify-your-hosts-file/)):

    127.0.0.1   keycloak

Build and start-up the project:

    docker-compose up -d

You'll then most likely want to run the [website setup steps](web/README.md#getting-setup).

When pulling new changes from master, it is sometimes necessary to run the following
if there are changes to the Docker config:

    docker-compose down && docker-compose build && docker-compose up -d


### Windows Subsystem for Linux

You will have to install the docker server on Windows, and the docker client on WSL.

To make this work, make the current path look like a Windows path to appease Docker for Windows:

    sudo ln -s /mnt/c /c
    cd /c/path/to/project

(from https://medium.com/software-development-stories/developing-a-dockerized-web-app-on-windows-subsystem-for-linux-wsl-61efec965080)


### Accounts

#### Keycloak

The local developer instance of Keycloak is configured with the following default user accounts:
* MSPSDS website: `user@example.com` / `password`
* Admin Console: `admin` / `admin`

Log in to the [Keycloak admin console](http://keycloak:8080/auth/admin) to add or edit users.

Ask someone on the team to create an account for you on the Int and Staging environments.

#### GOV.UK Notify

If you want to send emails from your development instance, or update any API keys for the deployed instances, you'll need an account for [GOV.UK Notify](https://www.notifications.service.gov.uk) - ask someone on the team to invite you.


#### Companies House

If you want to pull in business information from Companies House to your development instance, or update any API keys for the deployed instances, you'll need an account for [Companies House](https://developer.companieshouse.gov.uk/api/docs/) - ask someone on the team to invite you.


#### GOV.UK Platform as a Service

If you want to update any of the deployed instances, you'll need an account for [GOV.UK PaaS](https://www.cloud.service.gov.uk/) - ask someone on the team to invite you.


#### Amazon Web Services

We're using AWS to supplement the functionality of GOV.UK PaaS.
If you want to update any of the deployed instances, you'll need an account - ask someone on the team to invite you.


## Deployment

Anything which is merged to `master` (via a Pull Request or push) will trigger the [Travis CI build](https://travis-ci.org/UKGovernmentBEIS/beis-mspsds) and cause deployments of the various components to the int space ([the int website is hosted here](https://mspsds-int.cloudapps.digital/)) on GOV.UK PaaS.

Anything merged into the branch `staging` (only via a Pull Request) will cause Travis CI to instead build to the staging space ([staging website](https://mspsds-int.cloudapps.digital/)).
Please only do this if you are confident that this is a stable commit.


### Deployment from scratch

Once you have a GOV.UK PaaS account as mentioned above, you should install the Cloud Foundry CLI (`cf`) from https://github.com/cloudfoundry/cli#downloads and then run the following commands:

    cf login -a api.cloud.service.gov.uk -u XXX -p XXX
    cf target -o beis-mspsds

This will log you in and set the correct target organisation.

If you need to create a new environment, you can run `cf create-space SPACE-NAME`, otherwise, select the correct space using `cf target -o beis-mspsds -s SPACE-NAME`.

When setting up a new environment, you'll also need to create an AWS user called `mspsds-SPACE-NAME` and keep a note of the Access key ID and secret access key.
Give this user the AmazonS3FullAccess policy.


#### Database

To create a database for the current space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    cf create-service postgres tiny-unencrypted-9.5 mspsds-database

Larger database options should be considered if required.


#### Elasticsearch

To create an Elasticsearch instance for the current space:

    cf marketplace -s elasticsearch
    cf create-service elasticsearch small-ha-6.x mspsds-elasticsearch

There is current only one size for Elasticsearch.


#### Redis

To create a redis instance for the current space. 

    cf marketplace -s redis
    cf create-service redis tiny-unclustered-3.2 mspsds-redis

Larger options should be considered if required. The current worker (sidekiq) only works with the unclustered version.


#### S3

Create an S3 bucket named `mspsds-SPACE-NAME`. This bucket needs public _read_ access.


#### Keycloak

See [keycloak/README.md](keycloak/README.md#deployment-from-scratch).


#### Website

See [web/README.md](web/README.md#deployment-from-scratch).


#### Worker

See [worker/README.md](worker/README.md#deployment-from-scratch).


## Licence

Unless stated otherwise, the codebase is released under the MIT License. This covers both the codebase and any sample code in the documentation.

The documentation is © Crown copyright and available under the terms of the Open Government 3.0 licence.

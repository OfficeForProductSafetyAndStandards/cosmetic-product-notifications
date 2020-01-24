# Office for Product Safety & Standards Services

[![Build Status](https://travis-ci.org/UKGovernmentBEIS/beis-opss.svg?branch=master)](https://travis-ci.org/UKGovernmentBEIS/beis-opss)
[![Coverage Status](https://coveralls.io/repos/github/UKGovernmentBEIS/beis-opss/badge.svg?branch=master)](https://coveralls.io/github/UKGovernmentBEIS/beis-opss?branch=master)
[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=UKGovernmentBEIS/beis-opss)](https://dependabot.com)


## Getting Setup

This project includes [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), so when running `git clone` you need to add the `--recurse-submodules` option.
If you have already pulled, you can run `git submodule init` and then `git submodule update --recursive` instead.
You might also need to run `git submodule update --recursive` if the submodule is updated because of a pull.

Install Docker: https://docs.docker.com/install/.

Increase the memory available to Docker to at least 4GB (instructions for [Mac](https://docs.docker.com/docker-for-mac/#advanced), [Windows](https://docs.docker.com/docker-for-windows/#advanced)).

Copy the file in the root of the directory called `.env-template`.
Rename the copy of the file to `.env` and fill in any environment variables.
This `.env` file will be git ignored, so it is safe to add sensitive data.
See the [accounts section](#accounts) below for information on how to obtain some of the optional variables.

Build and start-up the full project:

    docker-compose up

Alternatively, you can run the specific component you're interested in using e.g. `docker-compose up cosmetics-web`.

You'll then most likely want to run the [Cosmetics setup steps](cosmetics-web/README.md#getting-setup).

When pulling new changes from master, it is sometimes necessary to run the following
if there are changes to the Docker config:

    docker-compose down && docker-compose build && docker-compose up


### Mac tips

[Docker shared volume performance is poor on Mac](https://docs.docker.com/docker-for-mac/osxfs-caching/) which can significantly affect e.g. asset compilation.
You can use docker-sync to speed up runtime:

    gem install docker-sync
    docker-sync-stack start


### Windows Subsystem for Linux

You will have to install the docker server on Windows, and the docker client on WSL.

To make this work, make the current path look like a Windows path to appease Docker for Windows:

    sudo ln -s /mnt/c /c
    cd /c/path/to/project

(from https://medium.com/software-development-stories/developing-a-dockerized-web-app-on-windows-subsystem-for-linux-wsl-61efec965080)
If the web container complains it can find files in the `/app` folder (e.g. `bin/bundle`), that might be sign you're in
the wrong directory.

You may also want to setup docker-sync using [these instructions](https://github.com/EugenMayer/docker-sync/wiki/docker-sync-on-Windows).


### Accounts

#### Keycloak

The local developer instance of Keycloak is configured with the following default user accounts:
* PSD website: `user@example.com` / `password`
* Admin Console: `admin` / `admin`

Log in to the [Keycloak admin console](http://keycloak:8080/auth/admin) to add or edit users.

Ask someone on the team to create an account for you on the Int and Staging environments.

#### GOV.UK Notify

If you want to send emails from your development instance, or update any API keys for the deployed instances,
you'll need an account for [GOV.UK Notify](https://www.notifications.service.gov.uk)
- ask someone on the team to invite you.


#### GOV.UK Platform as a Service

If you want to update any of the deployed instances, you'll need an account for
[GOV.UK PaaS](https://admin.london.cloud.service.gov.uk/) - ask someone on the team to invite you.


#### Amazon Web Services

We're using AWS to supplement the functionality of GOV.UK PaaS.
If you want to update any of the deployed instances, you'll need an account - ask someone on the team to invite you.
If you get an error saying you don't have permission to set something, make sure you have MFA set up.


## Deployment

Anything which is merged to `master` (via a Pull Request or push) will trigger the
[Travis CI build](https://travis-ci.org/UKGovernmentBEIS/beis-opss)
and cause deployments of the various components to the int space on GOV.UK PaaS.

Deployment to research environment does not currently happen automatically, for details see section "Research" in
[prototypes](https://regulatorydelivery.atlassian.net/wiki/spaces/PSD/pages/452689949/Prototypes)

Anything merged into the branch `staging` (only via a Pull Request) will cause Travis CI to instead build to the staging
space.
Please only do this if you are confident that this is a stable commit.

Anything merged into the branch `prod` (only via a Pull Request) will cause Travis CI to instead build to the prod
space.
Please only do this if you are confident that this is a stable commit.

### Review applications

In order to make PR review process fast and independent, there is possibility to create
short lived environment for given change. In order to do start your environment, run
`REVIEW_INSTANCE_NAME=ticket-123 ./cosmetics-web/deploy-review.sh`, where `ticket-123` is desired name of review app.

This will create 2 urls:
* `https://cosmetics-ticket-123-submit-web.london.cloudapps.digital`
* `https://cosmetics-ticket-123-search-web.london.cloudapps.digital`

And 2 applications (db is shared):
* cosmetics-ticket-123-web
* cosmetics-ticket-123-worker

By default, database is shared with all review apps, but it can be overriden by setting `DB_NAME` env variable.

### Deployment from scratch

Once you have a GOV.UK PaaS account as mentioned above, you should install the Cloud Foundry CLI (`cf`) from
https://github.com/cloudfoundry/cli#downloads and then run the following commands:

    cf login -a api.london.cloud.service.gov.uk -u XXX -p XXX
    cf target -o beis-opss

This will log you in and set the correct target organisation.
The login command without -u -p options will not work in some terminals, in particular git-bash. Passing username and
password in one line will.

If you need to create a new environment, you can run `cf create-space SPACE-NAME`, otherwise, select the correct space using `cf target -o beis-opss -s SPACE-NAME`.


#### Antivirus API

See [antivirus repo](https://github.com/UKGovernmentBEIS/beis-opss-antivirus).

#### Maintenance page

See [maintenance/README.md](maintenance/README.md#deployment).

#### Keycloak

See [keycloak repo](https://github.com/UKGovernmentBEIS/beis-opss-keycloak).

#### Cosmetics

See [cosmetics-web/README.md](cosmetics-web/README.md#deployment-from-scratch).

#### Other infrastructure

See [infrastructure/README.md](infrastructure/README.md).


## BrowserStack

[![BrowserStack](https://user-images.githubusercontent.com/7760/34738829-7327ddc4-f561-11e7-97e2-2fe0474eaf05.png)](https://www.browserstack.com)

We use [BrowserStack](https://www.browserstack.com) to test our service from a variety of different browsers and systems.


## Licence

Unless stated otherwise, the codebase is released under the MIT License. This covers both the codebase and any sample code in the documentation.

The documentation is © Crown copyright and available under the terms of the Open Government 3.0 licence.

# Office for Product Safety & Standards Services

[![Build Status](https://travis-ci.org/UKGovernmentBEIS/beis-opss.svg?branch=master)](https://travis-ci.org/UKGovernmentBEIS/beis-opss)
[![Coverage Status](https://coveralls.io/repos/github/UKGovernmentBEIS/beis-opss/badge.svg?branch=master)](https://coveralls.io/github/UKGovernmentBEIS/beis-opss?branch=master)
[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=UKGovernmentBEIS/beis-opss)](https://dependabot.com)


## Inviting Search Users

1. SSH to rails console (described below)
2. Run `InviteSearchUser.call name: 'Joe Doe', email: 'email@example.org', role: :poison_centre`
3. Role could be `poison_centre` or `msa`

## Getting Setup

### Quick steps

Add required hosts in `/etc/hosts`:

```
127.0.0.1       search_cosmetics
127.0.0.1       submit_cosmetics
```

Run docker compose:

`docker-compose up`

Go to app on [submit_cosmetics:3000](http://submit_cosmetics:3000)

### Long read

Install Docker: https://docs.docker.com/install/.

Increase the memory available to Docker to at least 4GB (instructions for [Mac](https://docs.docker.com/docker-for-mac/#advanced), [Windows](https://docs.docker.com/docker-for-windows/#advanced)).

See the [accounts section](#accounts) below for information on how to obtain some of the optional variables.

Add required hosts in `/etc/hosts`:

```
127.0.0.1       search_cosmetics
127.0.0.1       submit_cosmetics
```

Build and start-up the full project:

    docker-compose up

Alternatively, you can run the specific component you're interested in using e.g. `docker-compose up cosmetics-web`.

You'll then most likely want to run the [Cosmetics setup steps](cosmetics-web/README.md#getting-setup).

When pulling new changes from master, it is sometimes necessary to run the following
if there are changes to the Docker config:

    docker-compose down && docker-compose build && docker-compose up

Initialise the database:

    docker-compose run cosmetics-web bin/rake db:create db:schema:load

Restart the website (which may have crashed):

    docker-compose restart cosmetics-web

Visit the site on [submit_cosmetics:3000](http://submit_cosmetics:3000)

When pulling new changes from master, it is sometimes necessary to run the following
if there are new migrations:

    docker-compose exec cosmetics-web bin/rake db:migrate

### Running without docker

Running without docker is often more convinient for development. It is still advised to run all dependencies with docker compose:

`docker-compose up db redis elasticsearch`

Copy config files:
`cp cosmetics-web/.env.development.example cosmetics-web/.env.development`
`cp cosmetics-web/.env.test.example cosmetics-web/.env.test`

And run all steps required to setup rails app like bundle install, migrations etc.

### Troubleshooting



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
[Github Action Build](https://travis-ci.org/UKGovernmentBEIS/beis-opss)
and cause deployments of the various components to the int space on GOV.UK PaaS.

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

#### Debuging review application


Please run debug app deployment locally. See [".github/workflows/review-apps.yml"](https://github.com/UKGovernmentBEIS/beis-opss/blob/master/.github/workflows/review-apps.yml) for details.

### Deployment from scratch

Once you have a GOV.UK PaaS account as mentioned above, you should install the Cloud Foundry CLI (`cf`) from
https://github.com/cloudfoundry/cli#downloads and then run the following commands:

    cf login -a api.london.cloud.service.gov.uk -u XXX -p XXX
    cf target -o beis-opss

This will log you in and set the correct target organisation.
The login command without -u -p options will not work in some terminals, in particular git-bash. Passing username and
password in one line will.

If you need to create a new environment, you can run `cf create-space SPACE-NAME`, otherwise, select the correct space using `cf target -o beis-opss -s SPACE-NAME`.

The staging Cosmetics website is hosted [here](https://cosmetics-staging.london.cloudapps.digital/).

The production Cosmetics website is hosted [here](https://cosmetics-prod.london.cloudapps.digital/).


### Database

To create a database for the current space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    cf create-service postgres small-10.5 cosmetics-database

### Elasticsearch

To create an Elasticsearch instance for the current space:

    cf marketplace -s elasticsearch
    cf create-service elasticsearch tiny-7.x cosmetics-elasticsearch-7

### Redis

To create a redis instance for the current space.

    cf marketplace -s redis
    cf create-service redis tiny-3.2 cosmetics-queue

The current worker (sidekiq), which uses `cosmetics-queue` only works with an unclustered instance of redis.

### S3

When setting up a new environment, you'll also need to create an AWS user called `cosmetics-<<SPACE>>` and keep a note of the Access key ID and secret access key.
Create a policy for this user similar to the [Policy for Programmatic Access from the AWS docs](https://aws.amazon.com/blogs/security/writing-iam-policies-how-to-grant-access-to-an-amazon-s3-bucket/) but specifically for the new bucket.

Create an S3 bucket named `cosmetics-<<SPACE>>`.

### Configuration

Start by setting up the following credentials:

* To configure rails to use the production database amongst other things and set the server's encryption key (generate a new value by running `rake secret`):

    cf cups cosmetics-rails-env -p '{
        "RAILS_ENV": "production",
        "SECRET_KEY_BASE": "XXX"
    }'

* To configure AWS (see the S3 section [above](#s3) to get these values):

    cf cups cosmetics-aws-env -p '{
        "AWS_ACCESS_KEY_ID": "XXX",
        "AWS_SECRET_ACCESS_KEY": "XXX",
        "AWS_REGION": "XXX",
        "AWS_S3_BUCKET": "XXX"
    }'

* To configure Sentry

    cf cups cosmetics-sentry-env -p '{
        "SENTRY_DSN": "XXX",
        "SENTRY_CURRENT_ENV": "<<SPACE>>"
        "SENTRY_SECURITY_HEADER_ENDPOINT": "<<URL>>"
    }'

* To enable and add basic auth to the entire application (useful for deployment or non-production environments):

    cf cups cosmetics-auth-env -p '{
        "BASIC_AUTH_USERNAME": "XXX",
        "BASIC_AUTH_PASSWORD": "XXX"
    }'

* To enable and add basic auth to the health check endpoint at `/health/all`:

    cf cups cosmetics-health-env -p '{
        "HEALTH_CHECK_USERNAME": "XXX",
        "HEALTH_CHECK_PASSWORD": "XXX"
    }'

* To enable and add basic auth to the sidekiq monitoring UI at `/sidekiq`:

    cf cups cosmetics-sidekiq-env -p '{
        "SIDEKIQ_USERNAME": "XXX",
        "SIDEKIQ_PASSWORD": "XXX"
    }'

Once all the credentials are created, the app can be deployed using:

    SPACE=<<space>> ./cosmetics-web/deploy.sh

### Clound Foundry reference

#### Useful examples

Please take a look into github actions in `.github/workflows` to see how deployments are done.

#### Proper executable

If `cf` is not working, try `cf7`

#### Login to CF Api

```
cf login -a api.london.cloud.service.gov.uk -u some@email.com
```

#### SSH to service and run rails console

```
cf ssh APP-NAME

cd app && export $(./env/get-env-from-vcap.sh) && /tmp/lifecycle/launcher /home/vcap/app 'rails c' ''
```

#### List apps

```
cf apps
```

#### Show app details

```
cf app APP-NAME
```

#### Show app env

```
cf env APP-NAME
```

#### List services

```
cf apps
```

#### Antivirus API

See [antivirus repo](https://github.com/UKGovernmentBEIS/beis-opss-antivirus).

#### Maintenance page

See [maintenance in infrastructure repo](https://github.com/UKGovernmentBEIS/beis-opss-infrastructure/blob/master/maintenance/README.md).

#### Other infrastructure

See [infrastructure repository](https://github.com/UKGovernmentBEIS/beis-opss-infrastructure).


## BrowserStack

[![BrowserStack](https://user-images.githubusercontent.com/7760/34738829-7327ddc4-f561-11e7-97e2-2fe0474eaf05.png)](https://www.browserstack.com)

We use [BrowserStack](https://www.browserstack.com) to test our service from a variety of different browsers and systems.


## Licence

Unless stated otherwise, the codebase is released under the MIT License. This covers both the codebase and any sample code in the documentation.

The documentation is © Crown copyright and available under the terms of the Open Government 3.0 licence.

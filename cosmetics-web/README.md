# Cosmetics Website

This folder contains the configuration and code for the Cosmetics website.
This folder also contains the code for the [background worker](../cosmetics-worker/README.md).


## Overview

The site is written in [Ruby on Rails](https://rubyonrails.org/).

We're using [Slim](http://slim-lang.com/) as our HTML templating language, 
ES6 JavaScript and [Sass](https://sass-lang.com/) for styling transpiled with webpack.


## Getting Setup

This assumes you've followed the setup steps in [the root README](../README.md#getting-setup).

Initialise the database:

    docker-compose run cosmetics-web bin/rake db:create db:schema:load

Restart the website (which may have crashed):

    docker-compose restart cosmetics-web

Visit the site on [localhost:3002](http://localhost:3002)

When pulling new changes from master, it is sometimes necessary to run the following
if there are new migrations:

    docker-compose exec cosmetics-web bin/rake db:migrate


## Tests

You can run the tests with `docker-compose exec cosmetics-web bin/rspec`.

You can run the ruby linting with `docker-compose exec cosmetics-web bin/rubocop`.
Running this with the `--auto-correct` flag set will cause rubocop to attempt to fix as many of the issues as it can.

You can run the Slim linting with `docker-compose exec cosmetics-web bin/slim-lint -c vendor/shared-web/.slim-lint.yml app vendor`.

You can run the Sass linting with `docker-compose exec cosmetics-web yarn sass-lint -vq -c vendor/shared-web/.sasslint.yml 'app/**/*.scss' 'vendor/**/*.scss'`.

You can run the JavaScript linting with `docker-compose exec cosmetics-web yarn eslint -c vendor/shared-web/.eslintrc.yml app config vendor`.

You can run the security vulnerability static analysis with `bin/brakeman --no-pager`.


## Deployment

The website code is automatically deployed to the relevant environment by Travis
CI as described in [the root README](../README.md#deployment).

The int Cosmetics website is hosted [here](https://cosmetics-int.london.cloudapps.digital/).

The staging Cosmetics website is hosted [here](https://cosmetics-staging.london.cloudapps.digital/).

The production Cosmetics website is hosted [here](https://cosmetics-prod.london.cloudapps.digital/).


### Deployment from scratch

Login to GOV.UK PaaS and set the relevant space as described in [the root README](../README.md#deployment-from-scratch).

#### Database

To create a database for the current space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    cf create-service postgres small-10.5 cosmetics-database

#### Elasticsearch

To create an Elasticsearch instance for the current space:

    cf marketplace -s elasticsearch
    cf create-service elasticsearch tiny-6.x cosmetics-elasticsearch

#### Redis

To create a redis instance for the current space. 

    cf marketplace -s redis
    cf create-service redis tiny-3.2 cosmetics-queue

The current worker (sidekiq), which uses `cosmetics-queue` only works with an unclustered instance of redis.

#### S3

When setting up a new environment, you'll also need to create an AWS user called `cosmetics-SPACE-NAME` and keep a note of the Access key ID and secret access key.
Create a policy for this user similar to the [Policy for Programmatic Access from the AWS docs](https://aws.amazon.com/blogs/security/writing-iam-policies-how-to-grant-access-to-an-amazon-s3-bucket/) but specifically for the new bucket.

Create an S3 bucket named `cosmetics-SPACE-NAME`.

#### Cosmetics Website

Running the following commands from the root directory will then setup the website app:

    NO_START=true SPACE=<<space>> ./cosmetics-web/deploy.sh

This provisions the app in Cloud Foundry.

    cf set-env cosmetics-web RAILS_ENV production

This configures rails to use the production database amongst other things.

    cf set-env cosmetics-web COSMETICS_HOST XXX

This is the URL for the website and is used for generating redirect links.

    cf set-env cosmetics-web SECRET_KEY_BASE XXX

This sets the server's encryption key. Generate a new value by running `rake secret` 

    cf set-env cosmetics-web BASIC_AUTH_ENABLED true
    cf set-env cosmetics-web BASIC_AUTH_USERNAME XXX
    cf set-env cosmetics-web BASIC_AUTH_PASSWORD XXX

This enables and sets the username and password for HTTP Basic Authentication.

    cf set-env cosmetics-web AWS_ACCESS_KEY_ID XXX
    cf set-env cosmetics-web AWS_SECRET_ACCESS_KEY XXX
    cf set-env cosmetics-web AWS_REGION XXX
    cf set-env cosmetics-web AWS_S3_BUCKET XXX

See the S3 section [above](#s3) to get these values.

    cf set-env cosmetics-web SENTRY_DSN XXX
    cf set-env cosmetics-web SENTRY_CURRENT_ENV [int|staging|prod]

See the Sentry account section in [the root README](../README.md#sentry) to get this value.

    cf set-env mspsds-web SIDEKIQ_USERNAME XXX
    cf set-env mspsds-web SIDEKIQ_PASSWORD XXX

This enables and adds basic auth to the sidekiq monitoring UI at `/sidekiq` which can be used to check the worker performance.

The app can then be started using `cf start cosmetics-web`.


#### Cosmetics Worker

See [cosmetics-worker/README.md](../cosmetics-worker/README.md#deployment-from-scratch).

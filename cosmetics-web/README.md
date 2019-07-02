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

If you need to access the 'submit' and 'search' variants of the service separately, add the following entries to your
hosts file ([instructions](https://support.rackspace.com/how-to/modify-your-hosts-file/)):

    127.0.0.1   submit_cosmetics
    127.0.0.1   search_cosmetics

and update the `SUBMIT_HOST` and `SEARCH_HOST` values in your local `.env` file to match. After restarting the website,
you should then be able to access the two versions of the site on [submit_cosmetics:3002](http://submit_cosmetics:3002)
and [search_cosmetics:3002](http://search_cosmetics:3002).


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

When setting up a new environment, you'll also need to create an AWS user called `cosmetics-<<SPACE>>` and keep a note of the Access key ID and secret access key.
Create a policy for this user similar to the [Policy for Programmatic Access from the AWS docs](https://aws.amazon.com/blogs/security/writing-iam-policies-how-to-grant-access-to-an-amazon-s3-bucket/) but specifically for the new bucket.

Create an S3 bucket named `cosmetics-<<SPACE>>`.

#### Cosmetics Website

This assumes that you've run [the deployment from scratch steps for Keycloak](../keycloak/README.md#deployment-from-scratch)

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

* To configure Sentry (see the Sentry account section in [the root README](../README.md#sentry) to get these values):

    cf cups cosmetics-sentry-env -p '{
        "SENTRY_DSN": "XXX",
        "SENTRY_CURRENT_ENV": "<<SPACE>>"
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

* `cosmetics-keycloak-env` should already be setup from [the keycloak steps](../keycloak/README.md#setup-clients).

Once all the credentials are created, the app can be deployed using:

    SPACE=<<space>> ./cosmetics-web/deploy.sh


#### Cosmetics Worker

See [cosmetics-worker/README.md](../cosmetics-worker/README.md#deployment-from-scratch).

# Cosmetics Website

This folder contains the code for the Cosmetics website.
This folder also contains the code for the (background worker)[../cosmetics-worker/README.md].

## Overview

The site is written in [Ruby on Rails](https://rubyonrails.org/).

We're using the GOV.UK Design System.
The documentation for this can be found [here](https://design-system.service.gov.uk/).

We're using [Slim](http://slim-lang.com/) as our HTML templating language, vanilla ES5 JavaScript and [Sass](https://sass-lang.com/) for styling.


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

You can run the tests with `docker-compose exec cosmetics-web bin/rake test`.

You can run the ruby linting with `docker-compose exec cosmetics-web bin/rubocop`.
Running this with the `--auto-correct` flag set will cause rubocop to attempt to fix as many of the issues as it can.

You can run the Slim linting with `docker-compose exec cosmetics-web bin/slim-lint -c vendor/shared-web/.slim-lint.yml app/views`.

You can run the Sass linting with `docker-compose exec cosmetics-web yarn sass-lint -vq -c vendor/shared-web/.sasslint.yml 'app/assets/stylesheets/**/*.scss'`.

You can run the JavaScript linting with `docker-compose exec cosmetics-web yarn eslint -c vendor/shared-web/.eslintrc.yml app/assets/javascripts`.

You can run the security vulnerability static analysis with `bin/brakeman --no-pager`.

## Deployment

The website code is automatically deployed to the relevant environment by Travis
CI as described in [the root README](../README.md#deployment).

The int Cosmetics website is hosted [here](https://cosmetics-int.london.cloudapps.digital/).


### Deployment from scratch

Login to GOV.UK PaaS and set the relevant space as described in [the root README](../README.md#deployment-from-scratch).

#### Database

To create a database for the current space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    cf create-service postgres tiny-unencrypted-10.5 cosmetics-database

Larger database options should be considered if required.


#### Redis

To create a redis instance for the current space. 

    cf marketplace -s redis
    cf create-service redis tiny-unclustered-3.2 cosmetics-redis

Larger options should be considered if required. The current worker (sidekiq) only works with the unclustered version.


#### Cosmetics Website

Running the following commands from the root directory will then setup the website app:

    NO_START=true SPACE=<<space>> ./cosmetics-web/deploy.sh

This provisions the app in Cloud Foundry.

    cf set-env cosmetics-web RAILS_ENV production

This configures rails to use the production database amongst other things.

    cf set-env cosmetics-web SECRET_KEY_BASE XXX

This sets the server's encryption key. Generate a new value by running `rake secret` 

The app can then be started using `cf start mspsds-web`.


#### Cosmetics Worker

See [cosmetics-worker/README.md](../cosmetics-worker/README.md#deployment-from-scratch).

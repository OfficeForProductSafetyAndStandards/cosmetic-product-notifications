# Notify Cosmetics Website

This folder contains the code for the Notify Cosmetics website.

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

Visit the site on [localhost:3002](http://localhost:3000)

When pulling new changes from master, it is sometimes necessary to run the following
if there are new migrations:

    docker-compose exec cosmetics-web bin/rake db:migrate

## Tests

You can run the tests with `docker-compose exec cosmetics-web bin/rake test`.

You can run the ruby linting with `docker-compose exec cosmetics-web bin/rubocop` (or simply `bin/rubocop` if you installed ruby locally for the [IDE Setup section](#ide-setup) above).
Running this with the `--auto-correct` flag set will cause rubocop to attempt to fix as many of the issues as it can.

You can run the Slim linting with `docker-compose exec cosmetics-web bin/slim-lint app/views` (or simply `bin/slim-lint app/views` if installed locally).

You can run the Sass linting with `docker-compose exec cosmetics-web yarn sass-lint -vq -c vendor/shared-web/.sasslint.yml 'app/assets/stylesheets/**/*.scss'`.

You can run the JavaScript linting with `docker-compose exec cosmetics-web yarn eslint app/assets/javascripts`.

You can run the security vulnerability static analysis with `bin/brakeman --no-pager`.

## Deployment

The website code is automatically deployed to the relevant environment by Travis
CI as described in [the root README](../README.md#deployment).

### Deployment from scratch

Login to GOV.UK PaaS and set the relevant space as described in [the root README](../README.md#deployment-from-scratch).
Running the following commands from the root directory will then setup the website app:

    cf push -f ./web/manifest.yml --no-start --hostname mspsds-<SPACE>

This provisions the app in Cloud Foundry.

    cf set-env mspsds-web RAILS_ENV production

This configures rails to use the production database amongst other things.

The app can then be started using `cf restart cosmetics-web`.

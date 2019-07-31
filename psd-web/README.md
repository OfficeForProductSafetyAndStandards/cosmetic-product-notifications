# Product safety database Website

This folder contains the configuration and code for the PSD website.
This folder also contains the code for the [background worker](../psd-worker/README.md).


## Overview

The site is written in [Ruby on Rails](https://rubyonrails.org/).

We're using [Slim](http://slim-lang.com/) as our HTML templating language,
ES6 JavaScript and [Sass](https://sass-lang.com/) for styling transplied with webpack.

## Getting Setup

This assumes you've followed the setup steps in [the root README](../README.md#getting-setup).

Initialise the database:

    docker-compose run psd-web bin/rake db:create db:schema:load

You can add some sample data using:

    docker-compose run psd-web bin/rake db:seed

Restart the website (which may have crashed):

    docker-compose restart psd-web

Visit the site on [localhost:3000](http://localhost:3000)
(default credentials: `user@example.com` / `password`)

When pulling new changes from master, it is sometimes necessary to run the following
if there are new migrations:

    docker-compose exec psd-web bin/rake db:migrate

### Runing the app locally outside of docker

Run:

    bin/run_local

This runs `psd-web` and `psd-worker` locally, directly on your machine outside of docker, and uses docker-compose to run a minimum set of backing services.

All logs and output will appear on the terminal, use Ctl-C to stop the app and allow the rest of the `run_local` script to perform it's clean-up operations.

While the app is running, you may use all the usual rails, rake and other usual development commands in a different terminal. you should notice that the performance of tests and the running of the app in the browser are significantly improved.

#### Caveats

- Only works on Mac
- Assumes you have homebrew installed


### VS Code Setup

You should install the recommended extensions when prompted.

In order to get things like code completion and linting, it's necessary to install ruby locally.

To make managing ruby versions easier, you can use [rbenv](https://github.com/rbenv/rbenv).
Once rbenv is installed, run the following commands:

    # Install the version of ruby specified in `.ruby-version`.
    rbenv install
    # Install bundler
    gem install bundler
    # Install the project gems to enable code completion and linting
    bin/bundle install

### RubyMine Setup

If using RubyMine, you can base your Ruby SDK on the docker-compose-managed ruby installation.
1. Go to `Settings` -> `Languages & Frameworks` -> `Ruby SDK & Gems`
1. Click the `+` button and choose `Remote`
1. Choose `Docker Compose` and set `Service` to `psd-web`, click OK and select the newly created SDK

RubyMine comes with db inspection tools, too. To connect to the dev db, you'll need the following config:
`jdbc:postgresql://localhost:5432/psd_development`, empty password.
(note, RM may have created a db configuration automatically, but it'll have gotten some bits wrong, namely host)

### Debugging

Debugging is available by running `docker-compose -f docker-compose.yml -f docker-compose.debug.yml up psd-web` and then
- the `Docker: Attach to PSD` configuration, if in VS Code.
- the `Remote Debug` configuration, if in RubyMine
Note, that when run in this mode, the website won't launch until the debugger is connected!

You can access the [rails console](https://guides.rubyonrails.org/command_line.html#rails-console) using `docker-compose exec psd-web bin/rails console`.

If your Docker VM uses an IP other than `localhost`, you will need to change the `remoteHost` property in `launch.json` (accessed by clicking the cog icon next to the debug configuration in VS Code).


## Tests

You can run the tests with `docker-compose exec psd-web bin/rake test`.

You can run the ruby linting with `docker-compose exec psd-web bin/rubocop`.
Running this with the `--auto-correct` flag set will cause rubocop to attempt to fix as many of the issues as it can.

You can run the Slim linting with `docker-compose exec psd-web bin/slim-lint -c vendor/shared-web/.slim-lint.yml app vendor`.

You can run the Sass linting with `docker-compose exec psd-web yarn sass-lint -vq -c vendor/shared-web/.sasslint.yml 'app/**/*.scss' 'vendor/**/*.scss'`.

You can run the JavaScript linting with `docker-compose exec psd-web yarn eslint -c vendor/shared-web/.eslintrc.yml app config vendor`.

You can run the security vulnerability static analysis with `bin/brakeman --no-pager`.


## Deployment

The website code is automatically deployed to the relevant environment by Travis
CI as described in [the root README](../README.md#deployment).


### Deployment from scratch

Login to GOV.UK PaaS and set the relevant space as described in [the root README](../README.md#deployment-from-scratch).

#### Database

To create a database for the current space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    cf create-service postgres small-10.5 psd-database


#### Elasticsearch

To create an Elasticsearch instance for the current space:

    cf marketplace -s elasticsearch
    cf create-service elasticsearch tiny-6.x psd-elasticsearch


#### Redis

To create a redis instance for the current space.

    cf marketplace -s redis
    cf create-service redis tiny-3.2 psd-queue
    cf create-service redis tiny-3.2 psd-session

The current worker (sidekiq), which uses `psd-queue` only works with an unclustered instance of redis.


#### S3

When setting up a new environment, you'll also need to create an AWS user called `psd-<<SPACE>>` and keep a note of the Access key ID and secret access key.
Give this user the AmazonS3FullAccess policy.

Create an S3 bucket named `psd-<<SPACE>>`.


#### PSD Website

This assumes that you've run [the deployment from scratch steps for Keycloak](../keycloak/README.md#deployment-from-scratch)

Start by setting up the following credentials:

* To configure rails to use the production database amongst other things and set the server's encryption key (generate a new value by running `rake secret`):

    cf cups psd-rails-env -p '{
        "RAILS_ENV": "production",
        "SECRET_KEY_BASE": "XXX"
    }'

* To configure AWS (see the S3 section [above](#s3) to get these values):

    cf cups psd-aws-env -p '{
        "AWS_ACCESS_KEY_ID": "XXX",
        "AWS_SECRET_ACCESS_KEY": "XXX",
        "AWS_REGION": "XXX",
        "AWS_S3_BUCKET": "XXX"
    }'

* To configure Notify for email sending and previewing (see the GOV.UK Notify account section in [the root README](../README.md#gov.uk-notify) to get this value):

    cf cups psd-notify-env -p '{
        "NOTIFY_API_KEY": "XXX"
    }'

* To set pgHero http auth username and password for (see confluence for values):

    cf cups psd-pghero-env -p '{
        "PGHERO_USERNAME": "XXX",
        "PGHERO_PASSWORD": "XXX"
    }'

* To configure Sentry (see the Sentry account section in [the root README](../README.md#sentry) to get these values):

    cf cups psd-sentry-env -p '{
        "SENTRY_DSN": "XXX",
        "SENTRY_CURRENT_ENV": "<<SPACE>>"
    }'

* To enable and add basic auth to the entire application (useful for deployment or non-production environments):

    cf cups psd-auth-env -p '{
        "BASIC_AUTH_USERNAME": "XXX",
        "BASIC_AUTH_PASSWORD": "XXX"
    }'

* To enable and add basic auth to the health check endpoint at `/health/all`:

    cf cups psd-health-env -p '{
        "HEALTH_CHECK_USERNAME": "XXX",
        "HEALTH_CHECK_PASSWORD": "XXX"
    }'

* To enable and add basic auth to the sidekiq monitoring UI at `/sidekiq`:

    cf cups psd-sidekiq-env -p '{
        "SIDEKIQ_USERNAME": "XXX",
        "SIDEKIQ_PASSWORD": "XXX"
    }'

* `psd-keycloak-env` should already be setup from [the keycloak steps](../keycloak/README.md#setup-clients).

Once all the credentials are created, the app can be deployed using:

    SPACE=<<space>> ./psd-web/deploy.sh


#### PSD Worker

See [psd-worker/README.md](../psd-worker/README.md#deployment-from-scratch).

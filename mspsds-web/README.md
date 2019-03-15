# MSPSDS Website

This folder contains the configuration and code for the MSPSDS website.
This folder also contains the code for the [background worker](../mspsds-worker/README.md).


## Overview

The site is written in [Ruby on Rails](https://rubyonrails.org/).

We're using [Slim](http://slim-lang.com/) as our HTML templating language, 
ES6 JavaScript and [Sass](https://sass-lang.com/) for styling transplied with webpack.

## Getting Setup

This assumes you've followed the setup steps in [the root README](../README.md#getting-setup).

Initialise the database:

    docker-compose run mspsds-web bin/rake db:create db:schema:load

You can add some sample data using:

    docker-compose run mspsds-web bin/rake db:seed

Restart the website (which may have crashed):

    docker-compose restart mspsds-web

Visit the site on [localhost:3000](http://localhost:3000)
(default credentials: `user@example.com` / `password`)

When pulling new changes from master, it is sometimes necessary to run the following
if there are new migrations:

    docker-compose exec mspsds-web bin/rake db:migrate


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
1. Choose `Docker Compose` and set `Service` to `mspsds-web`, click OK and select the newly created SDK

RubyMine comes with db inspection tools, too. To connect to the dev db, you'll need the following config:
`jdbc:postgresql://localhost:5432/mspsds_development`, empty password.
(note, RM may have created a db configuration automatically, but it'll have gotten some bits wrong, namely host)

### Debugging

Debugging is available by running `docker-compose -f docker-compose.yml -f docker-compose.debug.yml up mspsds-web` and then 
- the `Docker: Attach to MSPSDS` configuration, if in VS Code.
- the `Remote Debug` configuration, if in RubyMine
Note, that when run in this mode, the website won't launch until the debugger is connected!

You can access the [rails console](https://guides.rubyonrails.org/command_line.html#rails-console) using `docker-compose exec mspsds-web bin/rails console`.

If your Docker VM uses an IP other than `localhost`, you will need to change the `remoteHost` property in `launch.json` (accessed by clicking the cog icon next to the debug configuration in VS Code).


## Tests

You can run the tests with `docker-compose exec mspsds-web bin/rake test`.

You can run the ruby linting with `docker-compose exec mspsds-web bin/rubocop`.
Running this with the `--auto-correct` flag set will cause rubocop to attempt to fix as many of the issues as it can.

You can run the Slim linting with `docker-compose exec mspsds-web bin/slim-lint -c vendor/shared-web/.slim-lint.yml app vendor`.

You can run the Sass linting with `docker-compose exec mspsds-web yarn sass-lint -vq -c vendor/shared-web/.sasslint.yml 'app/**/*.scss' 'vendor/**/*.scss'`.

You can run the JavaScript linting with `docker-compose exec mspsds-web yarn eslint -c vendor/shared-web/.eslintrc.yml app config vendor`.

You can run the security vulnerability static analysis with `bin/brakeman --no-pager`.


## Deployment

The website code is automatically deployed to the relevant environment by Travis
CI as described in [the root README](../README.md#deployment).

The int MSPSDS website is hosted [here](https://mspsds-int.london.cloudapps.digital/).

The staging MSPSDS website is hosted [here](https://mspsds-staging.london.cloudapps.digital/).

The production MSPSDS website is hosted [here](https://mspsds-prod.london.cloudapps.digital/).


### Deployment from scratch

Login to GOV.UK PaaS and set the relevant space as described in [the root README](../README.md#deployment-from-scratch).

#### Database

To create a database for the current space:

    cf marketplace -s postgres
    cf enable-service-access postgres
    cf create-service postgres small-10.5 mspsds-database


#### Elasticsearch

To create an Elasticsearch instance for the current space:

    cf marketplace -s elasticsearch
    cf create-service elasticsearch tiny-6.x mspsds-elasticsearch


#### Redis

To create a redis instance for the current space. 

    cf marketplace -s redis
    cf create-service redis tiny-3.2 mspsds-queue
    cf create-service redis tiny-3.2 mspsds-session

The current worker (sidekiq), which uses `mspsds-queue` only works with an unclustered instance of redis.


#### S3

When setting up a new environment, you'll also need to create an AWS user called `mspsds-SPACE-NAME` and keep a note of the Access key ID and secret access key.
Give this user the AmazonS3FullAccess policy.

Create an S3 bucket named `mspsds-SPACE-NAME`.


#### MSPSDS Website

Running the following commands from the root directory will then setup the website app:

    NO_START=true SPACE=<<space>> ./mspsds-web/deploy.sh

This provisions the app in Cloud Foundry.

    cf set-env mspsds-web RAILS_ENV production

This configures rails to use the production database amongst other things.

    cf set-env mspsds-worker MSPSDS_HOST XXX

This is the URL for the website and is used for generating redirect links.

    cf set-env mspsds-web SECRET_KEY_BASE XXX

This sets the server's encryption key. Generate a new value by running `rake secret` 

    cf set-env mspsds-web AWS_ACCESS_KEY_ID XXX
    cf set-env mspsds-web AWS_SECRET_ACCESS_KEY XXX
    cf set-env mspsds-web AWS_REGION XXX
    cf set-env mspsds-web AWS_S3_BUCKET XXX

See the S3 section [above](#s3) to get these values.

    cf set-env mspsds-web PGHERO_USERNAME XXX
    cf set-env mspsds-web PGHERO_PASSWORD XXX

This sets the http auth username and password for access to the pgHero dashboard. See confluence for values. 

    cf set-env mspsds-web SENTRY_DSN XXX
    cf set-env mspsds-web SENTRY_CURRENT_ENV [int|staging|prod]

See the Sentry account section in [the root README](../README.md#sentry) to get this value.

    cf set-env mspsds-web HEALTH_CHECK_USERNAME XXX
    cf set-env mspsds-web HEALTH_CHECK_PASSWORD XXX

This enables and adds basic auth to the health check endpoint at `/health/all` which can be polled to check the site status.

    cf set-env mspsds-web SIDEKIQ_USERNAME XXX
    cf set-env mspsds-web SIDEKIQ_PASSWORD XXX

This enables and adds basic auth to the sidekiq monitoring UI at `/sidekiq` which can be used to check the worker performance.

The app can then be started using `cf start mspsds-web`.


#### MSPSDS Worker

See [mspsds-worker/README.md](../mspsds-worker/README.md#deployment-from-scratch).

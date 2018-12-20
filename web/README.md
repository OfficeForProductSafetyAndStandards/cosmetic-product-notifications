# MSPSDS Website

This folder contains the configuration and code for the MSPSDS website.
This folder also contains the code for the (background worker)[../mspsds-worker/README.md].


## Overview

The site is written in [Ruby on Rails](https://rubyonrails.org/).

We're using the GOV.UK Design System.
The documentation for this can be found [here](https://design-system.service.gov.uk/).

We're using [Slim](http://slim-lang.com/) as our HTML templating language, vanilla ES5 JavaScript and [Sass](https://sass-lang.com/) for styling.


## Getting Setup

This assumes you've followed the setup steps in [the root README](../README.md#getting-setup).

Initialise the database:

    docker-compose run mspsds-web bin/rake db:create db:schema:load

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

Debugging is available by running `docker-compose -f docker-compose.yml -f docker-compose.debug.yml up` and then 
- the `Docker: Attach to Ruby` configuration, if in VS Code.
- the `Remote Debug` configuration, if in RubyMine
Note, that when run in this mode, the website won't launch until the debugger is connected!

You can access the [rails console](https://guides.rubyonrails.org/command_line.html#rails-console) using `docker-compose exec mspsds-web bin/rails console`.

If your Docker VM uses an IP other than `localhost`, you will need to change the `remoteHost` property in `launch.json` (accessed by clicking the cog icon next to the debug configuration in VS Code).


## Tests

You can run the tests with `docker-compose exec mspsds-web bin/rake test`.

You can run the ruby linting with `docker-compose exec mspsds-web bin/rubocop` (or simply `bin/rubocop` if you installed ruby locally for the [IDE Setup section](#ide-setup) above).
Running this with the `--auto-correct` flag set will cause rubocop to attempt to fix as many of the issues as it can.

You can run the Slim linting with `docker-compose exec mspsds-web bin/slim-lint app/views` (or simply `bin/slim-lint app/views` if installed locally).

You can run the Sass linting with `docker-compose exec mspsds-web yarn sass-lint -vq -c .sasslint.yml 'app/assets/stylesheets/**/*.scss'`.

You can run the JavaScript linting with `docker-compose exec mspsds-web yarn eslint app/assets/javascripts`.

You can run the security vulnerability static analysis with `bin/brakeman --no-pager`.


## Deployment

The website code is automatically deployed to the relevant environment by Travis
CI as described in [the root README](../README.md#deployment).


### Deployment from scratch

Login to GOV.UK PaaS and set the relevant space as described in [the root README](../README.md#deployment-from-scratch).
Running the following commands from the root directory will then setup the website app:

    NO_START=no-start SPACE=<<space>> ./mspsds-web/deploy.sh

This provisions the app in Cloud Foundry.

    cf set-env mspsds-web RAILS_ENV production

This configures rails to use the production database amongst other things.

    cf set-env mspsds-web SECRET_KEY_BASE XXX

This sets the server's encryption key. Generate a new value by running `rake secret` 

    cf set-env mspsds-web AWS_ACCESS_KEY_ID XXX
    cf set-env mspsds-web AWS_SECRET_ACCESS_KEY XXX
    cf set-env mspsds-web AWS_REGION XXX
    cf set-env mspsds-web AWS_S3_BUCKET XXX

See the AWS account section in [the root README](../README.md#aws) to get these values.

    cf set-env mspsds-web COMPANIES_HOUSE_API_KEY XXX

See the Companies House account section in [the root README](../README.md#companies-house) to get this value.

    cf set-env mspsds-web PGHERO_USERNAME XXX
    cf set-env mspsds-web PGHERO_PASSWORD XXX

This sets the http auth username and password for access to the pgHero dashboard. See confluence for values. 

    cf set-env mspsds-web SENTRY_DSN XXX
    cf set-env mspsds-web SENTRY_CURRENT_ENV [int|staging|prod]

See the Sentry account section in [the root README](../README.md#sentry) to get this value.

The app can then be started using `cf restart mspsds-web`.

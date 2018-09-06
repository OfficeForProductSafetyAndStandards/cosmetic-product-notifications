# MSPSDS Website

This folder contains the configuration and code for the MSPSDS website.
This folder also contains the code for the (background worker)[../worker/README.md].


## Overview

The site is written in [Ruby on Rails](https://rubyonrails.org/).

We're using the GOV.UK Design System.
The documentation for this can be found [here](https://design-system.service.gov.uk/).

We're using [Slim](http://slim-lang.com/) as our HTML templating language, vanilla ES5 JavaScript and [Sass](https://sass-lang.com/) for styling.


## Getting Setup

This assumes you've followed the setup steps in [the root README](../README.md#getting-setup).

Initialise the databse:
    docker-compose run web bin/rake db:create db:schema:load
    docker-compose run -e ADMIN_EMAIL=XXX -e ADMIN_PASSWORD=XXX web bin/rake db:seed

Restart the website (which may have crashed):
    docker-compose restart web

Visit the site on [localhost:3000](http://localhost:3000).

When pulling new changes from master, it is sometimes necesary to run:
* `docker-compose exec web bin/rake db:migrate` if there are new migrations.


### IDE Setup

VS Code is the preferred IDE.
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


### Debugging

If using VS Code, debugging is available by running `docker-compose up -f docker-compose.yml -f docker-compose.debug.yml` and then the `Docker: Attach to Ruby` configuration in VS Code.

You can access the [rails console](https://guides.rubyonrails.org/command_line.html#rails-console) using `docker-compose exec web bin/rails console`.


## Tests

You can run the tests with `docker-compose exec web bin/rake test`.

You can run the ruby linting with `docker-compose exec web bin/rubocop` (or simply `bin/rubocop` if you installed ruby locally for the [IDE Setup section](#ide-setup) above).
Running this with the `--auto-correct` flag set will cause rubocop to attempt to fix as many of the issues as it can.

You can run the Slim linting with `docker-compose exec web bin/slim-lint app/views` (or simply `bin/slim-lint app/views` if installed locally).

You can run the Sass linting with `docker-compose exec web yarn sass-lint -vq -c .sasslint.yml 'app/assets/stylesheets/**/*.scss'`.

You can run the JavaScript linting with `docker-compose exec web yarn eslint app/assets/javascripts`.

You can run the security vulnerability static analysis with `bin/brakeman --no-pager`.


## Deployment

The website code is automatically deployed to the relevant environment by Travis CI as described in [the root README](../README.md#deployment).


### Deployment from scratch

Login to GOV.UK PaaS and set the relevant space as described in [the root README](../README.md#deployment-from-scratch).
Running the following commands from the root directory will then setup the website app:

    cf push -f ./web/manifest.yml --no-start

This provisions the app in Cloud Foundry.

    cf set-env mspsds-web RAILS_ENV production

This configures rails to use the production database amongst other things.

    cf set-env mspsds-web USERNAME XXX
    cf set-env mspsds-web PASSWORD XXX

This sets the username and password for the HTTP Basic Authentication.

    cf set-env mspsds-web AWS_ACCESS_KEY_ID XXX
    cf set-env mspsds-web AWS_SECRET_ACCESS_KEY XXX
    cf set-env mspsds-web AWS_REGION XXX
    cf set-env mspsds-web AWS_S3_BUCKET XXX

See the AWS account section in [the root README](../README.md#aws) to get these values.

    cf set-env mspsds-web NOTIFY_API_KEY XXX

See the GOV.UK Notify account section in [the root README](../README.md#gov.uk-notify) to get this value.

    cf set-env mspsds-web COMPANIES_HOUSE_API_KEY XXX

See the Companies House account section in [the root README](../README.md#companies-house) to get this value.

    cf set-env mspsds-web MSPSDS_HOST XXX

This is the URL for the website and is used for sending emails.

The app can then be started using `cf restart mspsds-web`.

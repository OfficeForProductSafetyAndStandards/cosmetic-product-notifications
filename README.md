# Market Surveillance & Product Safety Digital Service

[![Build Status](https://travis-ci.org/UKGovernmentBEIS/beis-mspsds.svg?branch=master)](https://travis-ci.org/UKGovernmentBEIS/beis-mspsds)
[![Coverage Status](https://coveralls.io/repos/github/UKGovernmentBEIS/beis-mspsds/badge.svg?branch=master)](https://coveralls.io/github/UKGovernmentBEIS/beis-mspsds?branch=master)
[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=UKGovernmentBEIS/beis-mspsds)](https://dependabot.com)


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

Add the following entry for Keycloak to your hosts file ([instructions](https://support.rackspace.com/how-to/modify-your-hosts-file/)):

    127.0.0.1   keycloak

Build and start-up the full project:

    docker-compose up

Alternatively, you can run the specific component you're interested in using e.g. `docker-compose up mspsds-web` or `docker-compose up cosmetics-web`.

You'll then most likely want to run the [Cosmetics setup steps](cosmetics-web/README.md#getting-setup) or [MSPSDS setup steps](mspsds-web/README.md#getting-setup).

When pulling new changes from master, it is sometimes necessary to run the following
if there are changes to the Docker config:

    docker-compose down && docker-compose build && docker-compose up


### Windows Subsystem for Linux

You will have to install the docker server on Windows, and the docker client on WSL.

To make this work, make the current path look like a Windows path to appease Docker for Windows:

    sudo ln -s /mnt/c /c
    cd /c/path/to/project

(from https://medium.com/software-development-stories/developing-a-dockerized-web-app-on-windows-subsystem-for-linux-wsl-61efec965080)
If the web container complains it can find files in the `/app` folder (e.g. `bin/bundle`), that might be sign you're in
the wrong directory.


### Accounts

#### Keycloak

The local developer instance of Keycloak is configured with the following default user accounts:
* MSPSDS website: `user@example.com` / `password`
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


#### Logit

We're using [Logit](https://logit.io) as a hosted log management solution.
If you want to view the logs, you'll need an account - ask someone on the team to invite you.


#### Sentry

We're using [Sentry](https://sentry.io) to monitor exceptions.
If you want to view the exceptions, you'll need an account - ask someone on the team to invite you.


## Deployment

Anything which is merged to `master` (via a Pull Request or push) will trigger the
[Travis CI build](https://travis-ci.org/UKGovernmentBEIS/beis-mspsds)
and cause deployments of the various components to the int space on GOV.UK PaaS.

Anything merged into the branch `staging` (only via a Pull Request) will cause Travis CI to instead build to the staging
space.
Please only do this if you are confident that this is a stable commit.

Anything merged into the branch `prod` (only via a Pull Request) will cause Travis CI to instead build to the prod
space.
Please only do this if you are confident that this is a stable commit.

### Deployment from scratch

Once you have a GOV.UK PaaS account as mentioned above, you should install the Cloud Foundry CLI (`cf`) from
https://github.com/cloudfoundry/cli#downloads and then run the following commands:

    cf login -a api.london.cloud.service.gov.uk -u XXX -p XXX
    cf target -o beis-mspsds

This will log you in and set the correct target organisation.

If you need to create a new environment, you can run `cf create-space SPACE-NAME`, otherwise, select the correct space using `cf target -o beis-mspsds -s SPACE-NAME`.


#### Keycloak

See [keycloak/README.md](keycloak/README.md#deployment-from-scratch).


#### Cosmetics

See [cosmetics-web/README.md](cosmetics-web/README.md#deployment-from-scratch).


#### MSPSDS

See [mspsds-web/README.md](mspsds-web/README.md#deployment-from-scratch).


#### Logging

To enable logging to Logit for the current space:

    cf cups logit-ssl-drain -l syslog-tls://ENDPOINT:PORT

Where the endpoint can be obtained from Logit.

Setting up a logstash filter as follows may be useful:

    if [message] =~ "\[RTR\/" {
      grok {
        # Cloud Foundry RTR logs
        match => { "message" => "^%{NUMBER} <%{NUMBER:cf_pri:int}>%{NUMBER:cf_ver:int} %{TIMESTAMP_ISO8601:cf_ts} %{DATA:cf_org}\.%{DATA:cf_env}\.%{DATA:cf_app} %{UUID:cf_app_id} \[%{WORD:cf_type}/%{GREEDYDATA:cf_type_info}\] - - %{HOSTNAME:server_host} - \[%{TIMESTAMP_ISO8601:server_ts}\] \"%{WORD:verb} %{URIPATHPARAM:path} %{PROG:http_spec}\" %{BASE10NUM:status:int} %{BASE10NUM:request_bytes_received:int} %{BASE10NUM:body_bytes_sent:int} \"%{GREEDYDATA:referer}\" \"%{GREEDYDATA:http_user_agent}\" \"%{IPORHOST:src_host}:%{POSINT:src_port:int}\" \"%{IPORHOST:dst_host}:%{POSINT:dst_port:int}\" x_forwarded_for:\"%{GREEDYDATA:x_forwarded_for}\" x_forwarded_proto:\"%{GREEDYDATA:x_forwarded_proto}\" vcap_request_id:\"%{NOTSPACE:vcap_request_id}\" response_time:%{NUMBER:response_time_sec:float} app_id:\"%{UUID:cf_app_id}\" app_index:\"%{BASE10NUM:cf_app_index:int}\" %{GREEDYDATA:extra_headers}$" }
      }
    } else if [message] =~ "\[APP\/" {
      grok {
        # Cloud Foundry APP logs
        match => { "message" => "^%{NUMBER} <%{NUMBER:cf_pri:int}>%{NUMBER:cf_ver:int} %{TIMESTAMP_ISO8601:cf_ts} %{DATA:cf_org}\.%{DATA:cf_env}\.%{DATA:cf_app} %{UUID:cf_app_id} \[%{WORD:cf_type}/%{GREEDYDATA:cf_type_info}\] - - %{GREEDYDATA:msg}$" }
      }
    }


## Licence

Unless stated otherwise, the codebase is released under the MIT License. This covers both the codebase and any sample code in the documentation.

The documentation is © Crown copyright and available under the terms of the Open Government 3.0 licence.

# Antivirus server

This folder contains the code for an antivirus API.


## Overview

The site is written in [Ruby](https://www.ruby-lang.org/en/) using [Sinatra](http://sinatrarb.com/) and uses the [clamav](https://www.clamav.net/) to scan the files.


## Getting Setup

The antivirus server should be running if you've followed the steps in [the root README](../README.md#getting-setup).


## Deployment

* Run `docker build -t beisopss/antivirus .` from this directory.
* Login using the docker CLI and run `docker push beisopss/antivirus`.
* Login using the CloudFoundry CLI and then run `cf push --docker-image beisopss/antivirus --hostname antivirus-$SPACE` from this directory.


### Deployment from scratch

Set the following environment variables:

    cf set-env antivirus APP_ENV production

This will configure sinatra to run in production mode.

    cf set-env antivirus ANTIVIRUS_USERNAME XXX
    cf set-env antivirus ANTIVIRUS_PASSWORD XXX

This will set HTTP basic auth for the API.

    cf set-env antivirus HEALTH_USERNAME XXX
    cf set-env antivirus HEALTH_PASSWORD XXX

This will set HTTP basic auth for the health check.

Finally, create the following credentials for other applications to consume:

    cf cups antivirus-auth-env -p '{
        "ANTIVIRUS_URL": "XXX",
        "ANTIVIRUS_USERNAME": "XXX",
        "ANTIVIRUS_PASSWORD": "XXX"
    }'

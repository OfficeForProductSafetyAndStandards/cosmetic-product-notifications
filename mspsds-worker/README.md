# MSPSDS Background Worker

This folder contains the configuration to setup the worker processes which support the (website)[../mspsds-web/README.md].
The codebase is shared with the website.


## Overview

We're using [Sidekiq](https://github.com/mperham/sidekiq) as our background processor to do things like send emails and handle attachments.

We're processing attachments using our [antivirus API](../antivirus) for antivirus checking and [Imagemagick](http://imagemagick.org) for thumbnailing.


## Deployment

The worker code is automatically deployed to the relevant environment by Travis CI as
described in [the root README](../README.md#deployment).


### Deployment from scratch

This assumes that you've run [the deployment from scratch steps for the MSPSDS website](../mspsds-web/README.md#deployment-from-scratch) and [the deployment from scratch steps for the antivirus API](../antivirus/README.md#deployment-from-scratch).

Start by setting up the following credentials:

* `mspsds-aws-env`, `mspsds-notify-env`, `mspsds-rails-env` and `mspsds-sentry-env` should already be setup from the web steps.
* `antivirus-auth-env` should already be setup from the antivirus steps.

Once all the credentials are created, the app can be deployed using:

    ./mspsds-worker/deploy.sh

There's one final environment variable which is the URL for the website and is used for sending emails:

    cf set-env mspsds-worker MSPSDS_HOST XXX

This is set manually using an environment variable as it's dependent on how [the web deploy script](../mspsds-web/deploy.sh) works.

The app can then be started using `cf start mspsds-worker`.

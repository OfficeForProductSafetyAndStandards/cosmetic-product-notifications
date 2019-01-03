# Cosmetics Background Worker

This folder contains the configuration to setup the worker processes which support the (cosmetics website)[../cosmetics-web/README.md].
The codebase is shared with the website.


## Overview

We're using [Sidekiq](https://github.com/mperham/sidekiq) as our background processor to do things like send emails and
handle attachments.

We're processing attachments using [ClamAV](http://www.clamav.net/) for antivirus checking and [Imagemagick](http://imagemagick.org) for thumbnailing.
Due to how Cloud Foundry installs apt packages, there is some configuration to get ClamAV to run on GOV.UK PaaS.
This configuration is visible in [clamav](./clamav/), [deploy.sh](./deploy.sh) and [manifest.yml](./manifest.yml).


## Deployment

The worker code is automatically deployed to the relevant environment by Travis CI as
described in [the root README](../README.md#deployment).


### Deployment from scratch

This assumes that you've run [the deployment from scratch steps for the Cosmetics website](../cosmetics-web/README.md#deployment-from-scratch).
Running the following commands from the root directory will then setup the worker app.

    NO_START=no-start ./cosmetics-worker/deploy.sh

This provisions the app in Cloud Foundry.

    cf set-env cosmetics-worker RAILS_ENV production

This configures rails to use the production database amongst other things.

    cf set-env cosmetics-worker NOTIFY_API_KEY XXX

See the GOV.UK Notify account section in [the root README](../README.md#gov.uk-notify) to get this value.

    cf set-env cosmetics-worker COSMETICS_HOST XXX

This is the URL for the website and is used for sending emails.

The app can then be started using `cf start cosmetics-worker`.

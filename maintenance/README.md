# Maintenance page

This folder contains the code for a simple maintenance page.
The site is served when other apps are deploying / have been taken down for maintenance.


## Overview

The site is written in [Node](https://nodejs.org/) using [Express](https://expressjs.com/) and uses the [GOV.UK Design System](https://design-system.service.gov.uk/).


## Getting Setup

Install Node and Yarn and run the site using `yarn start`.


## Deployment

Login using the CloudFoundry CLI and then run `cf push` from this directory.


## Usage

We're doing blue-green deployments so using the maintenance page is a manual process.

To direct users to the maintenance page rather than an application, run:

    cf map-route maintenance <domain> --hostname <hostname>
    cf unmap-route <app> <domain> --hostname <hostname>

Once maintenance has finished:

    cf map-route <app> <domain> --hostname <hostname>
    cf unmap-route maintenance <domain> --hostname <hostname>

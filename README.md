[![Build Status](https://travis-ci.org/UKGovernmentBEIS/beis-mspsds.svg?branch=master)](https://travis-ci.org/UKGovernmentBEIS/beis-mspsds)
# BEIS - Market Surveillance & Product Safety Digital Service

## Getting Setup
Install Docker: https://docs.docker.com/install/

Install docker-compose: https://docs.docker.com/compose/install/

Copy the file `.env-template` to `.env` and fill in any environment variables.

```
docker-compose build
docker-compose up
```
Then in a different terminal initialise the DB
```
docker-compose run web rake db:create
# Run the migrations
docker-compose run web rake db:migrate
# Add an admin user
docker-compose run -e ADMIN_EMAIL=XXX -e ADMIN_PASSWORD=XXX web rails db:seed
```
Visit the site on localhost:3000

### Windows Subsystem for Linux
You will have to install the docker server on Windows, and the docker client on WSL

To make this work, make the current path look like a windows path to appease Windows Docker
```
sudo ln -s /mnt/c /c
cd /c/path/to/project
```

(from https://medium.com/software-development-stories/developing-a-dockerized-web-app-on-windows-subsystem-for-linux-wsl-61efec965080)

## Tests
You can run the tests with the following command:
```
docker-compose run web rails test
```

You can run the linting with:
```
docker-compose run web rubocop
```

Running this with the --auto-correct flag set will cause rubocop to attempt to fix as many of the issues as it can.

## Styles
This project is following the GOV UK style guides. We have used the GOV UK elements library to define CSS classes. The design guide for this is here: http://govuk-elements.herokuapp.com/.

## Licence

Unless stated otherwise, the codebase is released under the MIT License. This covers both the codebase and any sample code in the documentation.

The documentation is © Crown copyright and available under the terms of the Open Government 3.0 licence.

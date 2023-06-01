# Getting started

## Quick start with local app and Docker dependencies

The recommended setup is to use Docker for running dependencies such as PostgreSQL, Redis and OpenSearch,
and run the app itself locally. This allows for easier debugging and realtime refreshing on code changes.

Add the required hosts in `/etc/hosts`:

```
127.0.0.1       cosmetics-search
127.0.0.1       cosmetics-submit
127.0.0.1       cosmetics-support
```

To start all the required dependencies, run `docker compose up db redis opensearch`.

Make a copy of the environment files for development and test:

* `cp cosmetics-web/.env.development.example cosmetics-web/.env.development`
* `cp cosmetics-web/.env.test.example cosmetics-web/.env.test`

Run the usual Rails app setup steps:

* `bundle install`
* `bundle exec rails db:migrate`
* `yarn install`

If this is the first Ruby app you are setting up locally, you'll need to install a Ruby environment
manager such as `rbenv` or `asdf`, then install the Ruby version defined in the `.ruby-version` file.
You may also need to install bundler manually by running `gem install bundler` inside the root app
directory.

If this is the first Node.js app you are setting up locally, you'll need to install a Node.js
environment manager such as `nvm` or `asdf`, then install the Node.js version in the `.nvmrc` file.

## Quick start with Docker for both app and dependencies

It is also possible to run everything in Docker for a cleaner setup, but it will make debugging
(such as using `binding.pry`) more difficult due to the level of indirection.

Add the required hosts in `/etc/hosts`:

```
127.0.0.1       cosmetics-search
127.0.0.1       cosmetics-submit
127.0.0.1       cosmetics-support
```

Run Docker Compose: `docker compose up`.

Go to the app at [cosmetics-submit:3000](http://cosmetics-submit:3000).

### Working with Docker Compose

To start the application, run: `docker compose up cosmetics-web`.

To run a typical Rails command eg. database migration, run: `docker compose run cosmetics-web rake db:migrate`.

or tests: `docker compose run cosmetics-web rspec spec/some_specs`.

If the Dockerfile or Docker Compose configuration has changed since you last pulled your local branch,
run: `docker compose down && docker compose build && docker compose up`.

To initialise the database, run: `DISABLE_LOCAL_AUTOINDEX=true docker compose run cosmetics-web bin/rake db:create db:schema:load`.

### Mac tips

[Docker shared volume performance is poor on Mac](https://docs.docker.com/docker-for-mac/osxfs-caching/) which can significantly
affect processes such as asset compilation.

You can use the `docker-sync` gem to speed up runtime:

```
gem install docker-sync
docker-sync-stack start
```

### Windows Subsystem for Linux tips

You will have to install the Docker server on Windows, and the Docker client on WSL.

To make this work, make the current path look like a Windows path to appease Docker for Windows:

```
sudo ln -s /mnt/c /c
cd /c/path/to/project
```

(from https://medium.com/software-development-stories/developing-a-dockerized-web-app-on-windows-subsystem-for-linux-wsl-61efec965080)

If the web container complains it can't find files in the `/app` directory (e.g. `bin/bundle`), that might be sign you're in
the wrong directory.

You may also want to setup `docker-sync` using [these instructions](https://github.com/EugenMayer/docker-sync/wiki/docker-sync-on-Windows).

### Copying the staging database to your local database

The staging database contains a large amount of redacted data which can be useful when debugging issues or ensuring new
features work properly with old and new data.

To copy the staging database to your local database, run:

```
cf conduit cosmetics-database -- pg_dump --file staging_db.sql --no-acl --no-owner --clean
docker compose cp staging_db.sql db:/tmp
docker compose exec db psql -f /tmp/staging_db.sql -h localhost -d cosmetics_dev -U postgres
```

This will download a dump of the staging database, copy it into the correct Docker container and import it into your local
database. Note that all current data in your database will be deleted.

Since encryption secrets differ in each environment, after copying the staging database, you will need to reset the password
and 2FA secret for each account you want to log in with.

```
User.find_by(email: "email@example.com").reset_secondary_authentication!
```

The next time you log in with this user, you will be prompted to set up 2FA again.

To run these commands, you will need to install the `conduit` plugin for the Cloud Foundry CLI before running for the first time.
To do this, run `cf install-plugin conduit`.

# Review apps

Review apps are created automatically via a GitHub Action for each PR and can be accessed via the PR page.

However, they can also be created manually by running `REVIEW_INSTANCE_NAME=ticket-123 ./cosmetics-web/deploy-review.sh`,
where `ticket-123` is the desired name of the review app.

This will create 2 URLs:
* `https://cosmetics-ticket-123-submit-web.london.cloudapps.digital`
* `https://cosmetics-ticket-123-search-web.london.cloudapps.digital`

And 2 applications:
* cosmetics-ticket-123-web
* cosmetics-ticket-123-worker

By default, the database is shared with all review apps that use the same schema version, but this can be
overridden by setting the `DB_NAME` environment variable.

## Debugging review apps

The review app can be run locally to debug any issues. In general, the following script should work:

```
export SPACE=int
export WEB_MAX_THREADS=8
export WEB_CONCURRENCY=1
export WORKER_MAX_THREADS=10
export DB_VERSION=`cat cosmetics-web/db/schema.rb | grep 'ActiveRecord::Schema.define' | grep -o '[0-9_]\+'`
export PR_NUMBER=local-test-1
export REVIEW_INSTANCE_NAME=pr-$PR_NUMBER
export DB_NAME=cosmetics-pr-db-$DB_VERSION
export REDIS_NAME=cosmetics-review-redis-$PR_NUMBER
./cosmetics-web/deploy-review.sh
```

## Creating ad-hoc review apps

Ad-hoc, standalone review apps can be created for purposes such as user research:

`DB_NAME=cosmetics-db-2021_09_21_092542 REVIEW_INSTANCE_NAME=cosmetics-test REDIS_NAME=cosmetics-test-redis cosmetics-web/deploy-review.sh`

* `DB_NAME` is the name of the database
* `REVIEW_INSTANCE_NAME` is the name of the subdomain, eg, `REVIEW_INSTANCE_NAME=user-testing` will become `cosmetics-user-testing`
* `REDIS_NAME` is the name of the Redis instance

## Database

To make testing easier, we use a copy of staging data with extra notifications as a template.
The name of the template database is `cosmetics-database-template`. This template database is copied during
the review app deployment process, and the new instance is shared between all review apps that use the same
schema version since database creation takes a long time.

### Template database preparation

To dump the staging database, run:

```
cf conduit cosmetics-database -- pg_dump --file staging_db.sql --no-acl --no-owner
```

Use the dumped database on localhost so you can enhance the data:

```
psql 'postgres://localhost/cosmetics_local_staging?user=postgres' < staging_db.sql
```

Get notification names (not sensitive data) locally:

On production:

```
File.open('notification_names.csv', 'w') { |f| Notification.notification_complete.pluck(:product_name).each { |n| f.puts(n) }}
```

and download it to your local machine:

```
cf ssh cosmetics-web -c 'cat app/notification_names.csv' > notification_names.csv
```

On localhost, on staging DB, run:

```
bundle exec rails r db/seeds/enhance_db_with_extra_data.rb
```

Please note that you need to have `notification_names.csv` file in the main directory.

Dump the enhanced database on localhost again:

```
pg_dump 'postgres://localhost/cosmetics_db?user=postgres' --file staging_enhanced_db.sql --no-acl --no-owner
```

And create the database on the review app:

```
cf conduit cosmetics-database-template -- psql < staging_enhanced_db.sql
```

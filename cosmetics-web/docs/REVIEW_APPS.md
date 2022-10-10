# Review applications

In order to make PR review process fast and independent, there is possibility to create
short lived environment for given change. In order to do start your environment, run
`REVIEW_INSTANCE_NAME=ticket-123 ./cosmetics-web/deploy-review.sh`, where `ticket-123` is desired name of review app.

This will create 2 urls:
* `https://cosmetics-ticket-123-submit-web.london.cloudapps.digital`
* `https://cosmetics-ticket-123-search-web.london.cloudapps.digital`

And 2 applications (db is shared):
* cosmetics-ticket-123-web
* cosmetics-ticket-123-worker

By default, database is shared with all review apps, but it can be overriden by setting `DB_NAME` env variable.

## Debuging review application

Please run debug app deployment locally. See [".github/workflows/review-apps.yml"](https://github.com/UKGovernmentBEIS/beis-opss/blob/master/.github/workflows/review-apps.yml) for details.

In general, script like this should be sufficient:

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

## Creating ad-hoc reviews apps

Useful for example for user testing:

```
DB_NAME=cosmetics-db-2021_09_21_092542 REVIEW_INSTANCE_NAME=cosmetics-test REDIS_NAME=cosmetics-test-redis cosmetics-web/deploy-review.sh
```

DB_NAME is name of database
REVIEW_INSTANCE_NAME is name of domain eg `REVIEW_INSTANCE_NAME=user-testing` will become `cosmetics-user-testing`
REDIS_NAME is name of redis instance

## Database

To make testing easier we are using copy of staging data with extra notifications.
The name of the template db is `cosmetics-db-staging-template`

To dump staging db:

```
cf conduit cosmetics-database -- pg_dump --file staging_db.sql --no-acl --no-owner
```

Use dumped db on localhost so you can enhance the data.

```
psql 'postgres://localhost/cosmetics_local_staging?user=postgres' < staging_db.sql
```

Get notification names (not sensitive data) locally:

On production:
```
File.open('notification_names.csv', 'w') { |f| Notification.notification_complete.pluck(:product_name).each { |n| f.puts(n) }};''
```

and download it to localhost:

```
cf ssh cosmetics-web -c 'cat app/notification_names.csv' > notification_names.csv
```

On localhost, on stagingg DB, run script:

`rails r db/seeds/enhance_db_with_extra_data.rb`

please note that you need to have `notification_names.csv` file in main directory.

Dump enhanced db on localhost again:

```
pg_dump 'postgres://localhost/cosmetics_db?user=postgres' --file staging_enhanced_db.sql --no-acl --no-owner
```

And create db on review app:

```
cf conduit cosmetics-database-template -- psql < staging_enhanced_db.sql
```

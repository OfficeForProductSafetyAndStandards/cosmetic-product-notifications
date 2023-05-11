# Deployment

Anything which is merged to `main` will trigger a [GitHub Action](https://github.com/OfficeForProductSafetyAndStandards/cosmetic-product-notifications/actions/workflows/deploy.yml)
and deploy the various components to the `int` space on GOV.UK PaaS.

## Deployment from scratch

Install the Cloud Foundry CLI (`cf`) from https://github.com/cloudfoundry/cli#downloads and then run the following commands:

```
cf login -a api.london.cloud.service.gov.uk -u XXX -p XXX
cf target -o beis-opss
```

This will log you in and set the correct target organisation.

The login command without -u -p options will not work in some terminals, in particular git-bash. Passing username and
password in one line will.

If you need to create a new environment, you can run `cf create-space SPACE-NAME`, otherwise,
select the correct space using `cf target -o beis-opss -s SPACE-NAME`.

The staging SCPN app is hosted at https://cosmetics-staging.london.cloudapps.digital/.

The production SCPN app is hosted at https://cosmetics-prod.london.cloudapps.digital/.

### Database

To create a database for the current space:

```
cf marketplace -s postgres
cf enable-service-access postgres
cf create-service postgres small-13 cosmetics-database
```

### OpenSearch

To create an OpenSearch instance for the current space:

```
cf marketplace -s opensearch
cf create-service opensearch tiny-1 cosmetics-opensearch-1
```

### Redis

To create a Redis instance for the current space.

```
cf marketplace -s redis
cf create-service redis tiny-3.2 cosmetics-queue
```

Sidekiq currently only works with an unclustered instance of Redis.

### AWS S3

When setting up a new environment, you'll also need to create an AWS user called `cosmetics-<<SPACE>>` and
keep a note of the Access key ID and secret access key.

Create a policy for this user similar to the [Policy for Programmatic Access from the AWS docs](https://aws.amazon.com/blogs/security/writing-iam-policies-how-to-grant-access-to-an-amazon-s3-bucket/) but specifically for the new bucket.

Create an S3 bucket named `cosmetics-<<SPACE>>`.

### Configuration

Start by setting up the following credentials:

* To configure rails to use the production database amongst other things and set the server's encryption key (generate a new value by running `rake secret`):

    cf cups cosmetics-rails-env -p '{
        "RAILS_ENV": "production",
        "SECRET_KEY_BASE": "XXX"
    }'

* To configure AWS (see the S3 section [above](#s3) to get these values):

    cf cups cosmetics-aws-env -p '{
        "AWS_ACCESS_KEY_ID": "XXX",
        "AWS_SECRET_ACCESS_KEY": "XXX",
        "AWS_REGION": "XXX",
        "AWS_S3_BUCKET": "XXX"
    }'

* To configure Sentry

    cf cups cosmetics-sentry-env -p '{
        "SENTRY_DSN": "XXX",
        "SENTRY_CURRENT_ENV": "<<SPACE>>"
        "SENTRY_SECURITY_HEADER_ENDPOINT": "<<URL>>"
    }'

* To enable and add basic auth to the entire application (useful for non-production environments):

    cf cups cosmetics-auth-env -p '{
        "BASIC_AUTH_USERNAME": "XXX",
        "BASIC_AUTH_PASSWORD": "XXX"
    }'

    If the username/password set up in this step are not accepted when trying to visit the page, you may need to [forward the authorization header](https://docs.cloud.service.gov.uk/deploying_services/use_a_custom_domain/#forwarding-headers)

* To enable and add basic auth to the health check endpoint at `/health/all`:

    cf cups cosmetics-health-env -p '{
        "HEALTH_CHECK_USERNAME": "XXX",
        "HEALTH_CHECK_PASSWORD": "XXX"
    }'

* To enable and add basic auth to the Sidekiq monitoring UI at `/sidekiq`:

    cf cups cosmetics-sidekiq-env -p '{
        "SIDEKIQ_USERNAME": "XXX",
        "SIDEKIQ_PASSWORD": "XXX"
    }'

* To enable and add basic auth to the Flipper feature flag UI at `/flipper`:

    cf cups cosmetics-flipper-env -p '{
        "FLIPPER_USERNAME": "XXX",
        "FLIPPER_PASSWORD": "XXX"
    }'

Once all the credentials are created, the app can be deployed using:

    SPACE=<<space>> ./cosmetics-web/deploy.sh

### Cloud Foundry reference

#### Useful examples

Please take a look at the GitHub Actions in `.github/workflows` to see how deployments are done.

#### Login to CF Api

```
cf login -a api.london.cloud.service.gov.uk -u some@email.com
```

#### SSH to service and run rails console

```
cf ssh APP-NAME
app/bin/tll bin/rails c
```

#### List apps

```
cf apps
```

#### Show app details

```
cf app APP-NAME
```

#### Show app env

```
cf env APP-NAME
```

#### List services

```
cf apps
```

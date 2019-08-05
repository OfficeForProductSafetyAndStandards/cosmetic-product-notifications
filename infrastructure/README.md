# Other infrastructure

## Environment variables

We're using [user-provided services](https://docs.cloudfoundry.org/devguide/services/user-provided.html#deliver-service-credentials-to-an-app) to load environment variables into our applications.
Running [get-env-from-vcap.sh](./env/get-env-from-vcap.sh) as part of the application startup will add credentials from any service named `*-env` to the current environment.


## Domains

We've setup our domains based on [the instructions provided by PaaS](https://docs.cloud.service.gov.uk/deploying_services/use_a_custom_domain).
This also enables a CDN for the URL so it's important that the `Cache-Control` header is being set correctly.
For each domain, we define a `<<SPACE>>` and `<<SPACE>>-temp` subdomain for hosting and blue-green deployments.
It's important that we also allow the `Authorization` header through the CDN for the basic auth on non-production environments.
The following command can be used to create the `cdn-route` service:

    cf create-service cdn-route cdn-route opss-cdn-route -c '{"domain": "<<domain1>>,<<domain2>>", "headers": ["Authorization"]}'


## Logging

### Fluentd

We're using [fluentd](https://www.fluentd.org/) to aggregate the logs and send them to both an [ELK stack](https://www.elastic.co/elk-stack) and S3 bucket for long term storage.

#### Deployment

Create or target a common space using `cf create-space common` or `cf target -o beis-opss -s common`.

Deploy the fluentd app by running `cf push --no-start --hostname <fluentd hostname>` from the `fluentd` folder.
`<fluentd hostname>` can be anything but the full domain will be used again below.

Once the app has been created, add the following environment variables for the Logit and S3 credentials.
The values can be found on the respective websites.

    cf set-env fluentd AWS_ACCESS_KEY_ID XXX
    cf set-env fluentd AWS_SECRET_ACCESS_KEY XXX
    cf set-env fluentd AWS_REGION XXX
    cf set-env fluentd AWS_S3_BUCKET XXX
    cf set-env fluentd LOGIT_STACK_ID XXX
    cf set-env fluentd LOGIT_PORT XXX

Once the environment variables are set, start the app using `cf start fluentd`.

To start sending logs from an application, create a log drain on the specific space using `cf cups opss-log-drain -l https://<fluentd domain from above>`
Then bind the service to each application using e.g. `cf bind-service psd-web opss-log-drain`.


### Logit

We're using [Logit](https://logit.io) as a hosted ELK stack.
If you want to view the logs, you'll need an account - ask someone on the team to invite you.
You should sign up using GitHub OAuth to ensure MFA.

[logstash-filters.conf](./logstash-filters.conf) provides a set of rules which logstash can use to parse logs.

We're using [ElastAlerts](https://github.com/Yelp/elastalert) within Logit to track the logs and send alerts in certain scenarios (eg. a spike in unsuccessful file uploads). 
The config files for these alerts can be found in the `elastalert` folder. 
Please note the email address and the Slack webhook URL are placeholder values and will need updating. These values can be obtained from the existing alerts on Logit.


### S3

We're using AWS S3 as a long term storage for logs.
See [the root README](../README.md#amazon-web-services) for more details about setting up an account.


## Monitoring

### Metrics

Our metrics are sent to an ELK stack and S3 using [the paas-metric-exporter app](./paas-metric-exporter).

We have set up a regular job to query the database and to print certain metrics into the logs. This was all done in [PR #962](https://github.com/UKGovernmentBEIS/beis-opss/pull/962).
The metrics are sent in JSON format and logstash is clever enough to split these out into separate logs for each key-value pair. 
However, you will need to add an extra filter in [logstash-filters.conf](./logstash-filters.conf), in order to create new fields on the logs instead of the data all being captured in the `message` field.


#### Deployment

Create or target a common space using `cf create-space common` or `cf target -o beis-opss -s common`.

Deploy the app by running `cf push --no-start` from the `paas-metric-exporter` folder.
Once the app has been created, define the following environment variables:

Set the metrics to be logged to stdout using:
    
    cf set-env metric-exporter DEBUG true

Tell the app to connect to the London PaaS API

    cf set-env metric-exporter API_ENDPOINT https://api.london.cloud.service.gov.uk

Provide some credentials (these should be for a user with only the "Space auditor" permission on the spaces to be monitored) to connect to the API with:

    cf set-env metric-exporter USERNAME XXX
    cf set-env metric-exporter PASSWORD XXX

Follow the instructions above to create and bind the `opss-log-drain` to the `metric-exporter` app.

Finally, start the app using `cf start metric-exporter`.
Running `cf logs metric-exporter` should show metrics from all of the spaces that the user has the "Space auditor" permission for.


### Uptime check

We're using [UptimeRobot](https://uptimerobot.com) to perform a regular uptime check on our website.
If you want to receive emails, ask someone on the team to add you to the list of "Alert Contacts".


### Sentry

We're using [Sentry](https://sentry.io) to monitor exceptions.
If you want to view the exceptions, you'll need an account - ask someone on the team to invite you.
You should sign up using GitHub OAuth to ensure MFA.

# Smoke tests

> The smoke tests and text relay app are under review as of April 2023 and may change significantly.

The smoke tests are located at `spec/smoke/`.

The tests:

* Log in to the search service
* Search for an existing product
* Check if the product page displays relevant informations

The smoke tests are run against the production environment. This ensures all systems are operating correctly.

## Text relay app

The text relay app is located at `spec/smoke/beis-opps-text-relay`. See `spec/smoke/beis-opss-text-relay/README.md` for more details.
The app is used to receive 2FA SMS messages and make them available to the smoke tests.

## Running the smoke tests

To run the smoke tests:

```
SMOKE_ENV_URL='http://cosmetics-search:3000'
RUN_SMOKE=true
SMOKE_SEARCH_USER='email@example.com'
SMOKE_SEARCH_PASSWORD='password'
SMOKE_RELAY_CODE_URL='https://relay-service/'
SMOKE_PRODUCT_NAME='shower' rspec spec/smoke/search_smoke_test_spec.rb
```

The environment variables for the above command are as follows:

* `SMOKE_ENV_URL`: URL of the app (search) to run the tests against
* `RUN_SMOKE=true`: set to `true` to run the smoke tests
* `SMOKE_SEARCH_USER`: email of user which will be used to log in
* `SMOKE_SEARCH_PASSWORD`: password of user which will be used to log in
* `SMOKE_RELAY_CODE_URL`: URL of the text relay service
* `SMOKE_PRODUCT_NAME`: product name to search for; needs to exist for the tests to pass

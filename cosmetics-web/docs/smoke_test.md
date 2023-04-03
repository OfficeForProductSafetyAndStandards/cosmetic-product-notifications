# Smoke test

Smoke test is located in

```
spec/smoke/search_smoke_test_spec.rb
```
The test itself is very simple as it:
* Login to the search app
* Searches for the existing product
* Checks if the product page displays relevant informations

Smoke test is being run agains production environment. This gives quick check if the all systems are operating correctly.

## Text relay app

Text relay app is located in `spec/smoke/beis-opps-text-relay`
Please see `spec/smoke/beis-opss-text-relay/README.md`


## Running smoke test
To run smoke test run the command:

```
SMOKE_ENV_URL='http://search_cosmetics:3000'
RUN_SMOKE=true
SMOKE_SEARCH_USER='email@example.com'
SMOKE_SEARCH_PASSWORD='password'
SMOKE_RELAY_CODE_URL='https://relay-service/'
SMOKE_PRODUCT_NAME='shower' rspec spec/smoke/search_smoke_test_spec.rb
```

Env variables for above command are as follows:

`SMOKE_ENV_URL` - url of the app (search) that smoke test will be using
`RUN_SMOKE=true` - as smoke test is part of the rspec suite, it need to be set to `true`
`SMOKE_SEARCH_USER` - email of user which will be used to log in
`SMOKE_SEARCH_PASSWORD` - password of user which will be used to log in
`SMOKE_RELAY_CODE_URL` - url of the relay service
`SMOKE_PRODUCT_NAME` - produt name to search, need to exist as will be used to verify that system is running correctly


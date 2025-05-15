# Feature flags

The app uses [Flipper](https://github.com/jnunemaker/flipper) to manage feature flags.
This enables new or changed features to be deployed to production while switched off,
so that they can be tested, rolled out gradually or turned off if required while not
keeping long-lived PRs open.

Feature flags are not replicated automatically across environments and default to "off", so
if you are seeing unexpected behaviour, ensure the correct feature flag exists in your
environment first.

## User interface

A UI is available at `/flipper` to manage feature flags and their state in each environment.
It is password protected everywhere except for local development.

## Using feature flags

To check a feature flag is enabled, use `Flipper.enabled?(:billing)` where `:billing` is the
name of the feature flag.

## Available feature flags

### two_factor_authentication

Controls whether two-factor authentication (2FA) is required for users.

When disabled, users can log in without 2FA even if they have set it up. This is useful for
load testing and migration testing.

You can enable/disable this feature flag through the Flipper UI at `/flipper` or via the Rails console:

```ruby
# To enable 2FA
Flipper.enable(:two_factor_authentication)

# To disable 2FA
Flipper.disable(:two_factor_authentication)

# To check status
Flipper.enabled?(:two_factor_authentication)
```

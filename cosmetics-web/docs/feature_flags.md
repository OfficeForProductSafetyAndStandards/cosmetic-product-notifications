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

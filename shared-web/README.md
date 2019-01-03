# Shared Web

This folder contains a [Rails engine](https://guides.rubyonrails.org/engines.html) containing common code for OPSS web applications.

Features of this engine include:
- The [GOV.UK Design System](https://design-system.service.gov.uk/)
- Support for [GOV.UK Notify](https://www.notifications.service.gov.uk/)
- Various linting tools (e.g. rubocop, slim-lint)

# Installation

Add the following to your project's Gemfile:

```ruby
gem 'shared-web', path: '<path to shared web>'
```
and run `bundle install`

To add the shared NPM packages, run
```bash
yarn add <path to shared web>
```
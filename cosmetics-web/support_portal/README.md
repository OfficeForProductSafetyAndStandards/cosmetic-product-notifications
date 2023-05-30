# OSU Support Portal

The OSU Support Portal is used by the OSU support teams to administer SCPN.

Built by the [Office for Product Safety and Standards](https://www.gov.uk/government/organisations/office-for-product-safety-and-standards).

For enquiries, contact [opss.enquiries@beis.gov.uk](mailto:opss.enquiries@beis.gov.uk).

## Getting started

The OSU Support Portal is accessed from within the SCPN application.

To work on the OSU Support Portal, set up the SCPN application as usual, then in the `support_portal` directory, run `bundle install` and `yarn install`.

## Technical documentation

This is a Ruby on Rails engine packaged as a gem, and is used by the parent SCPN application.

It uses ERB for templating along with Sass for styling and ES6 for scripting.

### Migrations

Database migrations are contained in the `db/migrate` directory, but must be copied over to the SCPN application before running.
Once your migrations are ready, from the SCPN application root, run `bundle exec rails support_portal:install:migrations`.
You can then run the migrations as usual. All OSU Support Portal table names must be prefixed with `support_portal_` to avoid potential clashes
with SCPN tables.

### Accounts

#### GOV.UK Platform as a Service

This application is deployed to [GOV.UK PaaS](https://admin.london.cloud.service.gov.uk/) - ask someone on the team to invite you.

#### GOV.UK Notify

All emails and text messages are sent using [GOV.UK Notify](https://www.notifications.service.gov.uk) - ask someone on the team to invite you.

## Licence

[MIT licence](../LICENSE)

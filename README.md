# SCPN: Submit cosmetic product notifications

SCPN is a dual-purpose application used by organisations to notify the Office for Product Safety and Standards (OPSS) about cosmetic products available to consumers in Great Britain, and by approved public sector organisations to retrieve information about these notifications.

Built by the [Office for Product Safety and Standards](https://www.gov.uk/government/organisations/office-for-product-safety-and-standards).

For enquiries, contact [opss.enquiries@beis.gov.uk](opss.enquiries@beis.gov.uk).

## Getting started

See [getting started](cosmetics-web/docs/getting_started.md) for instructions on setting up this application locally.

## Technical documentation

This is a Ruby on Rails app.

It uses ERB for templating along with Sass for styling and ES6 for scripting. Sidekiq is used for background jobs.

### Antivirus API

The [antivirus API](https://github.com/OfficeForProductSafetyAndStandards/antivirus) is used to virus scan user-uploaded files.

### Maintenance app

The [maintenance app](https://github.com/OfficeForProductSafetyAndStandards/infrastructure/blob/master/maintenance/README.md) is used to display a holding page while the app is down for maintenance.

### Infrastructure

The [infrastructure repo](https://github.com/OfficeForProductSafetyAndStandards/infrastructure) contains Terraform code to set up some ancillary infrastructure for things like monitoring and alerting.

### Accounts

#### GOV.UK Platform as a Service

This application is deployed to [GOV.UK PaaS](https://admin.london.cloud.service.gov.uk/) - ask someone on the team to invite you.

#### GOV.UK Notify

All emails and text messages are sent using [GOV.UK Notify](https://www.notifications.service.gov.uk) - ask someone on the team to invite you.

#### Amazon Web Services

User-uploaded files are saved to AWS S3 - ask someone on the team to invite you.

## Additional documentation

* [Glossary of terms](cosmetics-web/docs/glossary.md)
* [Frame formulations](cosmetics-web/docs/frame_formulations.md)
* [ERDs](cosmetics-web/docs/erd.md)
* [Users and roles](cosmetics-web/docs/users_and_roles.md)
* [Review apps](cosmetics-web/docs/review_apps.md)
* [Code checks](cosmetics-web/docs/code_checks.md)
* [Deployment](cosmetics-web/docs/deployment.md)
* [Feature flags](cosmetics-web/docs/feature_flags.md)
* [Maintenance](cosmetics-web/docs/maintenance.md)
* [OpenSearch](cosmetics-web/docs/opensearch.md)
* [Smoke tests](cosmetics-web/docs/smoke_tests.md)
* [ActiveStorage notes](cosmetics-web/docs/active_storage_notes.md)

## Licence

[MIT licence](LICENSE)

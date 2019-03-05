# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
### MSPSDS
- Make the autocomplete arrow open the list.
- Add the "Create new case" button for TS users.
- Add clear button to autocompletes.
- Increase character limits on text inputs.
- Make error summaries more consistent across pages.
- Add a healthcheck endpoint.
- Enable sidekiq UI.
- Send confirmation email to current user on creation of a case.
- Add support for team mailboxes. When a team with one is supposed to be notified, the email will be sent just to
team mailbox, rather than to all of its members. 
- Provide "send email alert about this case" functionality.

<!-- ### Cosmetics -->

### Next release checklist
- [ ] Add `HEALTH_CHECK_USERNAME` and `HEALTH_CHECK_PASSWORD` environment variables.
- [ ] Add `SIDEKIQ_USERNAME` and `SIDEKIQ_PASSWORD` environment variables.
- [ ] Deploy the antivirus API.
- [ ] Add `ANTIVIRUS_URL`, `ANTIVIRUS_USERNAME` and `ANTIVIRUS_PASSWORD` environment variables.


## 2019-02-21
### General
- Added changelog

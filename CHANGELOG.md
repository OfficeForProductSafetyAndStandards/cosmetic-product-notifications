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
- Allow users to view their team members.

<!-- ### Cosmetics -->

### Next release checklist
- [ ] Add `HEALTH_CHECK_USERNAME` and `HEALTH_CHECK_PASSWORD` environment variables.
- [ ] Add `SIDEKIQ_USERNAME` and `SIDEKIQ_PASSWORD` environment variables.
- [ ] Deploy the antivirus API.
- [ ] Add `ANTIVIRUS_URL`, `ANTIVIRUS_USERNAME` and `ANTIVIRUS_PASSWORD` environment variables.
- [ ] Add `team_admin` role to mspsds client on keycloak

## 2019-02-21
### General
- Added changelog

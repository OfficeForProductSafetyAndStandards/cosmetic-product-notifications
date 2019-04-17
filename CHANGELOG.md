# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
<!-- ### Product safety database -->
- New service navigation

<!-- ### Cosmetics -->

### Next release checklist
- [ ] Update `cosmetics-app` name in keycloak
     1. Log into keycloak admin app, click on `Clients` and select `cosmetics-app`
         1. In the `Settings` tab, change the `Name` field to `Submit cosmetic product notifications`
         2. Press the `Save` button, to apply the changes
- [ ] Update all user accounts to use the `First Name` field for full name
     1. Log into the Keycloak admin app, click on the `Users` tab and select `View all users`
     2. Edit each user and ensure the `First Name` field contains their full name
     3. Set the `Last Name` field to `n/a` to indicate it is not used

## 2019-04-03
### Product safety database
- Update introduction, about page, terms and conditions and privacy notice.


## 2019-03-29
### Product safety database
- Rename the service to Product safety database.
- Add case alert functionality (to send RAPEX-style alerts).
- Add introduction slides, about page, terms and conditions and privacy policy.
- Add terms and conditions declaration prompt.
- Assign cases to their creator by default.
- Allow users to view their team members.
- Allow users to add new team members.
- Various bug fixes.

## 2019-03-07
### MSPSDS
- Make the autocomplete arrow open the list.
- Add the "Create new case" button for TS users.
- Add clear button to autocompletes.
- Increase character limits on text inputs.
- Make error summaries more consistent across pages.
- Add a healthcheck endpoint.
- Enable sidekiq UI.
- Move antivirus to a separate API.
- Send confirmation email to current user on creation of a case.
- Add support for team mailboxes. When a team with one is supposed to be notified, the email will be sent just to
team mailbox, rather than to all of its members.
- Add business type when adding a business to a case.


## 2019-02-21
### General
- Added changelog

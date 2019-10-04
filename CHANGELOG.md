# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
- Fix bug when updating cases

### Next release checklist
- [ ] Add `HEALTH_USERNAME` and `HEALTH_PASSWORD` environment variables to the antivirus server

## 2019-08-05
### Product safety database
- Filter by case type
- Filter by creator
- New service navigation
- Welcome email
- Product search
- Cookie banner
- Content fixes
- Case ID can now be searched by using an exact match (e.g 1907-001)

## 2019-04-23
### Product safety database
- Fixed a bug where the wrong user was attributed to entries in the activity log.
- Improvements to the display of error messages across the service.
- Various bug fixes.


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

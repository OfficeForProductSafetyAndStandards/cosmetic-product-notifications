# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
### MSPSDS
- Go to declaration page when user logs in until they accept.
- Provide "send email alert about this case" functionality.
- Allow users to view their team members.
- When emails and phone calls are marked as GDPR senstive, prevent other users from viewing them or their attachments.
- Show introduction slides the first time a non_opss user logs in.
- Cases are assigned to their creator by default
- Allow team_admin users to add new team members.

<!-- ### Cosmetics -->

### Next release checklist
- [ ] Add `team_admin` role to mspsds client on keycloak
- [ ] Allow mspsds to view clients info on keycloak
    # Log into keycloak admin app, click on `Clients` and select `mspsds-app`
    # In the `Service Account Roles` tab, select `realm-management` from the dropdown and assign the `view-clients` role
    # In the `Scope` tab, select `realm-management` from the dropdown and assign the `view-clients` role
- [ ] Update the apps to send their logs to `opss-log-drain`.
- [ ] Allow mspsds to manage users info on keycloak
    # Log into keycloak admin app, click on `Clients` and select `mspsds-app`
    # In the `Service Account Roles` tab, select `realm-management` from the dropdown and assign the `manage-users` role
    # In the `Scope` tab, select `realm-management` from the dropdown and assign the `manage-users` role
- [ ] Delete mspsds `admin` role (Clients->mspsds-app->roles->admin->delete)
- [ ] Create the new environment variable services.
- [ ] Create the `opss-cdn-route` service with the live and deployment URLs.


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

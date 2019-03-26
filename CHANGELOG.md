# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
### Product safety database
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
    1. Log into keycloak admin app, click on `Clients` and select `mspsds-app`
    1. In the `Service Account Roles` tab, select `realm-management` from the dropdown and assign the `view-clients` role
    1. In the `Scope` tab, select `realm-management` from the dropdown and assign the `view-clients` role
- [ ] Update the apps to send their logs to `opss-log-drain`.
- [ ] Allow mspsds to manage users info on keycloak
    1. Log into keycloak admin app, click on `Clients` and select `mspsds-app`
    1. In the `Service Account Roles` tab, select `realm-management` from the dropdown and assign the `manage-users` role
    1. In the `Scope` tab, select `realm-management` from the dropdown and assign the `manage-users` role
- [ ] Delete mspsds `admin` role (Clients->mspsds-app->roles->admin->delete)
- [ ] Create the new environment variable services.
- [ ] Create the `opss-cdn-route` service with the live and deployment URLs.
- [ ] Rename the `mspsds-app` client to `psd-app`
- [ ] Rename the `mspsds_user` role to `psd_user`
- [ ] Update the `psd-app` client to use the newly renamed `govuk-psd` theme
- [ ] Rename all `mspsds-*` CF services to `psd-*`
- [ ] Update keycloak setup to allow processing team members to manage users
    1. Log into keycloak admin app (master realm)
    1. Go to the `Groups` section, select `OPSS Processing` and press `Edit`
        1. Go to the `Role Mappings` tab, select `admin` from the `Realm Roles` and press `Add selected`
    1. Go to the `Roles` section and click on the `admin` role
        1. Under `Composite Roles` select `realm-management` from the dropdown
        1. Select `manage-users`, `view-clients` and `view-realm`, press `Add selected`


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

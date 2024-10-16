# Users and roles

## Users

This app uses [Devise](https://github.com/heartcombo/devise) for authentication. There are three types of user -
"search", "submit" and "support". Each can access the relevant service, but email addresses are unique across
all types of user since it is very rare for an individual to require access to all services simultaneously.
Support users can also access the search service with the OPSS General role using their support user credentials.

All types of user inherit most of their properties from a parent `User` model.

### Signup and invitations

Submit users can sign up for an account and set up a new Responsible Person, or be invited by an existing
user to join their Responsible Person.

Search and support users can only be invited by the SCPN team since their identity needs to be verified and
the correct role assigned (for search users).

To invite a new search user:

1. SSH and run the Rails console: `app/bin/tll bin/rails c`.
2. Run `InviteSearchUser.call(name: 'Joe Doe', email: 'email@example.org', role: :poison_centre)`.
3. The role can be one of `poison_centre`, `opss_general`, `opss_enforcement`, `opss_science` or `trading_standards`.

To invite a new support user:

1. SSH and run the Rails console: `app/bin/tll bin/rails c`.
2. Run `InviteSupportUser.call(name: 'Joe Doe', email: 'email@example.org')`.

### Two-factor authentication

See [secondary authentication](secondary_authentication.md).

## Roles

Only search users have roles.

There are six roles:

* Poison centre
* OPSS General
* OPSS Enforcement
* OPSS IMT
* OPSS Science
* Trading Standards

Each role has a different set of permissions. The `Privileges::SearchConcern` concern defines a number of
convenience methods for different permissions which are used throughout the app.

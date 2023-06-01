# Users and roles

## Users

This app uses [Devise](https://github.com/heartcombo/devise) for authentication. There are two types of user -
"search" and "submit". Each can access the relevant service, but email addresses are unique across both types
of user since it is very rare for an individual to require access to both services simultaneously.

Both types of user inherit most of their properties from a parent `User` model.

### Signup and invitations

Submit users can sign up for an account and set up a new Responsible Person, or be invited by an existing
user to join their Responsible Person.

Search users can only be invited by the SCPN team since their identity needs to be verified and the correct
role assigned.

To invite a new search user:

1. SSH and run the Rails console: `app/bin/tll bin/rails c`.
2. Run `InviteSearchUser.call(name: 'Joe Doe', email: 'email@example.org', role: :poison_centre)`.
3. The role can be one of `poison_centre`, `opss_general`, `opss_enforcement`, `opss_science` or `trading_standards`.

### Two-factor authentication

See [secondary authentication](secondary_authentication.md).

## Roles

Only search users have roles - any submit user can access all functions for their Responsible Person.

There are five roles:

* Poison centre
* OPSS General
* OPSS Enforcement
* OPSS Science
* Trading Standards

Each role has a different set of permissions. The `Privileges::SearchConcern` concern defines a number of
convenience methods for different permissions which are used throughout the app.

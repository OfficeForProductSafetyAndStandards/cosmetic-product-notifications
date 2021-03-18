# Simple app for relying sms for smoke test.

## API

Has 2 api endpoints:

```
POST /save
```
Example:

```
curl -d "message=text-msg" -u user:pass https://beis-opss-text-relay.some-domain/save
```

Where text send by virtual phone number is being relyied.

```
GET /text
```

Gets the last text. Used by smoketest.

Example:

```
curl -u user:pass https://beis-opss-text-relay.some-domain/text
```

## INFO

Text is being send to virtual number and relyied to this service.
Always use username/password.


## DEPLOY

Application is deployed to `staging` environment.

`cf push` for deployment

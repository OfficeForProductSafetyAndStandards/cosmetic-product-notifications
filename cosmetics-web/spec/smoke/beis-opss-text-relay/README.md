# Simple app for relying sms for smoke test.

## API

Has 2 api endpoints:

```
POST /save
```

Where text send by virtual phone number is being relyied.

```
GET /text
```

Gets the last text. Used by smoketest.

## INFO

Text is being send to virtual number and relyied to this service.
Always use username/password.


Application is deployed to `staging` environment.

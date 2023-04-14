# Maintenance

Sometimes, database migrations, infrastructure updates, etc., require making the app inaccessible.
We achieve this by redirecting the web requests to our application to a `maintenance` application
that displays a static HTML page.

There is a CLI tool at `bin/production-maintenance-mode` to set/unset maintenance mode.

To set the service to maintenance mode:

```
./bin/production-maintenance-mode on
```

To remove the service from maintenance mode:

```
./bin/production-maintenance-mode off
```

See the [maintenance app](https://github.com/OfficeForProductSafetyAndStandards/infrastructure/blob/master/maintenance/README.md) for more information.

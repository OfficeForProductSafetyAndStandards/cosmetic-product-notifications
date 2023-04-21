# Code checks

A number of checks are run automatically by GitHub each time a commit is pushed.
They can also be run locally.

## Linting

### rubocop (Ruby)

We use rubocop with all the default cops enabled and using the GOV.UK style wherever possible.
There are some exceptions in the `.rubocop.yml` file which we are working to remove.

You can run rubocop locally using `bundle exec rubocop`.

### standard (JavaScript)

We use [JavaScript Standard Style](https://github.com/standard/standard) with all the defaults.

You can run standard locally using `yarn lint:js`.

### stylelint (CSS)

We use [stylelint](https://github.com/stylelint/stylelint) with all the defaults and using the
GOV.UK style wherever possible.

You can run stylelint locally using `yarn lint:css`.

## Static analysis

We use [brakeman](https://github.com/presidentbeef/brakeman) to perform static analysis on the codebase
and flag any potential security issues.

False positives are ignored in `config/brakeman.ignore`.

You can run brakeman locally using `bundle exec brakeman`.

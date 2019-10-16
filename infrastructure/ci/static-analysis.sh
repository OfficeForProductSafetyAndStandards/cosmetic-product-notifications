#!/usr/bin/env bash
set -ex

cd cosmetics-web

bundle exec rubocop
bundle exec slim-lint app

yarn eslint app config
yarn sass-lint -c .sasslint.yml -vq 'app/**/*.scss'

bundle exec brakeman --no-pager

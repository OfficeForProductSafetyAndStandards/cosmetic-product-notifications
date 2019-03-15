#!/usr/bin/env bash
set -ex

if [[ $(./infrastructure/ci/get-changed-components.sh) =~ ((^| )$COMPONENT($| )) ]]; then
    echo "Running static analysis for component $COMPONENT"
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml pull
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm --no-deps $COMPONENT echo 'Gems pre-installed'
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml up -d $COMPONENT
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT bin/rubocop
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT bin/slim-lint -c vendor/shared-web/.slim-lint.yml app vendor
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT yarn eslint -c vendor/shared-web/.eslintrc.yml app config vendor
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT yarn sass-lint -vq -c vendor/shared-web/.sasslint.yml 'app/**/*.scss' 'vendor/**/*.scss'
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec $COMPONENT bin/brakeman --no-pager
    docker-compose -f docker-compose.yml -f docker-compose.ci.yml down
else
    echo 'Static analysis not required.'
fi

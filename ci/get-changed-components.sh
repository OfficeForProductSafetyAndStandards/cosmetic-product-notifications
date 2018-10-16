#!/usr/bin/env bash
set -ex

COMMITS=$TRAVIS_COMMIT_RANGE

# Get top level files / folders changed in recent commits
TOP_LEVEL_CHANGES=$(git diff --name-only $COMMITS | awk -F'/' '{ print $1 }' | sort -u)

COMPONENTS=''
if [[ "$TOP_LEVEL_CHANGES" =~ keycloak ]]; then
    COMPONENTS="$COMPONENTS keycloak"
fi

if [[ "$TOP_LEVEL_CHANGES" =~ web ]]; then
    COMPONENTS="$COMPONENTS web worker"
elif [[ "$TOP_LEVEL_CHANGES" =~ worker ]]; then
    COMPONENTS="$COMPONENTS worker"
fi

echo $COMPONENTS

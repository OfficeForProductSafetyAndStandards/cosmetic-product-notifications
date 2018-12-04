#!/usr/bin/env bash
set -ex

COMMITS=$TRAVIS_COMMIT_RANGE

# Get top level files / folders changed in recent commits
TOP_LEVEL_CHANGES=$(git diff --name-only $COMMITS | awk -F'/' '{ print $1 }' | sort -u)

COMPONENTS=''
if [[ "$TOP_LEVEL_CHANGES" =~ keycloak ]]; then
    COMPONENTS="$COMPONENTS keycloak"
fi

if [[ "$TOP_LEVEL_CHANGES" =~ db ]]; then
    COMPONENTS="$COMPONENTS db"
fi

if [[ "$TOP_LEVEL_CHANGES" =~ elasticseach ]]; then
    COMPONENTS="$COMPONENTS elasticseach"
fi

if [[ "$TOP_LEVEL_CHANGES" =~ cosmetics-web ]]; then
    COMPONENTS="$COMPONENTS cosmetics-web cosmetics-worker"
elif [[ "$TOP_LEVEL_CHANGES" =~ cosmetics-worker ]]; then
    COMPONENTS="$COMPONENTS cosmetics-worker"
fi

if [[ "$TOP_LEVEL_CHANGES" =~ shared-web ]]; then
    COMPONENTS="$COMPONENTS web worker cosmetics-web cosmetics-worker"
fi

if [[ "$TOP_LEVEL_CHANGES" =~ '^web$' ]]; then
    COMPONENTS="$COMPONENTS web worker"
elif [[ "$TOP_LEVEL_CHANGES" =~ worker ]]; then
    COMPONENTS="$COMPONENTS worker"
fi

echo $COMPONENTS

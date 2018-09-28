#!/usr/bin/env bash
set -ex

COMMITS=$TRAVIS_COMMIT_RANGE

# Get deployment components
VALID_COMPONENTS=$(find . -name '*manifest.yml' | awk -F'/' '{ print $2 }' | sort -u)

# Get top level files / folders changed in recent commits
TOP_LEVEL_CHANGES=$(git diff --name-only $COMMITS | awk -F'/' '{ print $1 }' | sort -u)

# Get intersection between the two
INTERSECTION=$(comm -1 -2 <(echo $VALID_COMPONENTS | tr ' ' '\n') <(echo $TOP_LEVEL_CHANGES | tr ' ' '\n'))

# If the count between TOP_LEVEL_CHANGES and INTERSECTION is different, then we must have had changes outside of VALID_COMPONENTS,
# so we should set CHANGED_COMPONENTS as empty and rebuild everything
TOP_LEVEL_CHANGES_COUNT=$(echo $TOP_LEVEL_CHANGES | wc -w | awk '{ print $1 }')
INTERSECTION_COUNT=$(echo $INTERSECTION | wc -w | awk '{ print $1 }')

[[ $TOP_LEVEL_CHANGES_COUNT == $INTERSECTION_COUNT ]] && echo $TOP_LEVEL_CHANGES || echo 'all'
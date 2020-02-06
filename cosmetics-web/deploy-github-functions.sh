#!/usr/bin/env bash
set -e

# Creates a Deploy in Github
#
# Input:
# - 1. Transient flag (optional): -t | --transient.
# - 2. Name of the environment to deploy at.
# - eg:  $ gh_deploy_create staging
# - eg:  $ gh_deploy_create -t review-app-15
# - eg:  $ gh_deploy_create --transient review-app-15
#
# Required environment variables:
# - GITHUB_TOKEN      - Github user token with deploy rights.
# - GITHUB_REPOSITORY - Set by default by Github. Formatted as "org/repo".
# - BRANCH            - Branch to be deployed.
# - GITHUB_REF        - Set by default by Github.
#
# Required system tools:
# - getopt
# - curl
# - jq
# - awk
gh_deploy_create() {
  # Set the environment as transient depending on a optionally
  # given flag when calling the function.
  if [[ $1 == "-t" || $1 == "--transient" ]]; then
    transient_environment=true
    shift # The second argument becomes $1
  else
    transient_environment=false
  fi
  environment_name=$1
  echo "Transient Environment: $transient_environment"

  deploy_url=$(curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.ant-man-preview+json" \
    https://api.github.com/repos/$GITHUB_REPOSITORY/deployments \
    -d '{
    "ref": "'"$BRANCH"'",
    "description": "'"$environment_name"' deploy created",
    "environment": "'"$environment_name"'",
    "transient_environment": '"$transient_environment"',
    "auto_merge": false,
    "required_contexts": []
    }' | jq '.url?' | tr -d '"') # Gets 'url' field from the response and trims the surronding quotes.

  if [ -z "$deploy_url" ]; then
    echo "Failed to create Github deployment"
  else
    # Need to be shared between steps
    echo "::set-env name=DEPLOY_STATUSES_URL::$deploy_url/statuses"
    echo "Github deployment created: $deploy_url"
  fi
}

# Sets Github deploy status as "in_progress"
#
# Input:
# - 1. Name of the deployment environment to update the status at.
# - 2. Url where the deployment progress can be tracked.
# - eg: $ gh_deploy_initiate staging https://github.com/user/repo/pull/15/checks
#
# Required environment variables:
# - GITHUB_TOKEN        - Github user token with deploy rights.
# - DEPLOY_STATUSES_URL - URL for Github deployment statuses. Set up by "gh_deploy_create".
#
# Required system tools:
# - curl
gh_deploy_initiate() {
  environment_name=$1
  log_url=$2

  curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.ant-man-preview+json" \
    -H "Accept: application/vnd.github.flash-preview+json" \
    $DEPLOY_STATUSES_URL \
    -d '{
      "environment": "'"$environment_name"'",
      "state": "in_progress",
      "description": "'"$environment_name"' deployment initiated",
      "log_url": "'"$log_url"'"
    }'
}

# Sets Github deploy status as "success"
#
# Input:
# - 1. Name of the deployment environment to update the status at.
# - 2. Url where the deployment progress can be tracked.
# - 3. Environment url where the deployed changes can be viewed.
# - eg: $ gh_deploy_success staging https://github.com/user/repo/pull/15/checks https://opss-service.digital/
#
# Required environment variables:
# - GITHUB_TOKEN        - Github user token with deploy rights.
# - DEPLOY_STATUSES_URL - URL for Github deployment statuses. Set by "gh_deploy_create".
#
# Required system tools:
# - curl
gh_deploy_success() {
  environment_name=$1
  log_url=$2
  environment_url=$3

  curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.ant-man-preview+json" \
    $DEPLOY_STATUSES_URL \
    -d '{
      "environment": "'"$environment_name"'",
      "state": "success",
      "description": "'"$environment_name"' deployment succeeded",
      "environment_url": "'"$environment_url"'",
      "log_url": "'"$log_url"'"
    }'
}

# Sets Github deploy status as "failure"
#
# Input:
# - 1. Name of the deployment environment to update the status at.
# - 2. Url where the deployment progress can be tracked.
# - eg: $ gh_deploy_failure staging https://github.com/user/repo/pull/15/checks
#
# Required environment variables:
# - GITHUB_TOKEN        - Github user token with deploy rights.
# - DEPLOY_STATUSES_URL - URL for Github deployment statuses. Set by "gh_deploy_create".
#
# Required system tools:
# - curl
gh_deploy_failure() {
  environment_name=$1
  log_url=$2
  curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.ant-man-preview+json" \
    $DEPLOY_STATUSES_URL \
    -d '{
      "environment": "'"$environment_name"'",
      "state": "failure",
      "description": "'"$environment_name"' deployment failed",
      "log_url": "'"$log_url"'"
    }'
}


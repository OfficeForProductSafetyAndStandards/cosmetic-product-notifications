#!/usr/bin/env bash
set -e

# Creates a Deploy in Github
#
# Input:
# - Name of the environment to deploy at.
#   eg: $ gh_deploy_create staging
#
# Required environment variables:
# - GITHUB_TOKEN      - Github user token with deploy rights.
# - GITHUB_REPOSITORY - Set by default by Github. Formatted as "org/repo".
# - BRANCH            - Branch to be deployed.
# - GITHUB_REF        - Set by default by Github.
#
# Required system tools:
# - curl
# - jq
# - awk
gh_deploy_create() {
  environment_name=$1

  if [[ $environment_name == review* ]]; then
    transient_environment=true
  else
    transient_environment=false
  fi

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
# - Name of the deployment environment to update the status at.
#   eg: $ gh_deploy_initiate staging
#
# Required environment variables:
# - GITHUB_TOKEN        - Github user token with deploy rights.
# - GITHUB_REPOSITORY   - Set by default by Github. Formatted as "org/repo".
# - PR_NUMBER           - Pull Request number. Only needed for review apps.
# - DEPLOY_STATUSES_URL - URL for Github deployment statuses. Set up by "gh_deploy_create".
#
# Required system tools:
# - curl
gh_deploy_initiate() {
  environment_name=$1
  if [[ $environment_name == review* ]]; then
    log_url=$(echo "https://github.com/$GITHUB_REPOSITORY/pull/$PR_NUMBER/checks")
  else
    log_url=$(echo "https://github.com/$GITHUB_REPOSITORY/actions?query=branch%3Amaster+workflow%3ADeploy")
  fi
  echo "::set-env name=LOG_URL::$log_url" # Export for future steps

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
# - 2. Environment url where the deployed changes can be viewed.
#   eg: $ gh_deploy_success staging https://opss-service.digital/
#
# Required environment variables:
# - GITHUB_TOKEN        - Github user token with deploy rights.
# - DEPLOY_STATUSES_URL - URL for Github deployment statuses. Set by "gh_deploy_create".
# - LOG_URL             - URL to track the deployment progress. Set by "gh_deploy_initiate".
#
# Required system tools:
# - curl
gh_deploy_success() {
  environment_name=$1
  environment_url=$2

  curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.ant-man-preview+json" \
    $DEPLOY_STATUSES_URL \
    -d '{
      "environment": "'"$environment_name"'",
      "state": "success",
      "description": "'"$environment_name"' deployment succeeded",
      "environment_url": "'"$environment_url"'",
      "log_url": "'"$LOG_URL"'"
    }'
}

# Sets Github deploy status as "failure"
#
# Input:
# - Name of the deployment environment to update the status at.
#   eg: $ gh_deploy_failure staging
#
# Required environment variables:
# - GITHUB_TOKEN        - Github user token with deploy rights.
# - DEPLOY_STATUSES_URL - URL for Github deployment statuses. Set by "gh_deploy_create".
# - LOG_URL             - URL to track the deployment progress. Set by "gh_deploy_initiate".
#
# Required system tools:
# - curl
gh_deploy_failure() {
  environment_name=$1
  curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.ant-man-preview+json" \
    $DEPLOY_STATUSES_URL \
    -d '{
      "environment": "'"$environment_name"'",
      "state": "failure",
      "description": "'"$environment_name"' deployment failed",
      "log_url": "'"$LOG_URL"'"
    }'
}


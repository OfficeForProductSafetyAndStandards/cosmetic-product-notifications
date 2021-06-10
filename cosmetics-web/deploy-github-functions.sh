#!/usr/bin/env bash
set -e

# Creates a Deploy in Github
#
# Input:
# - 1. Name of the environment to deploy at.
# - eg:  $ gh_deploy_create staging
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
  environment_name=$1

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN not set"
    exit 1
  fi

  deploy_url=$(curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.ant-man-preview+json" \
    https://api.github.com/repos/$GITHUB_REPOSITORY/deployments \
    -d '{
    "ref": "'"$BRANCH"'",
    "description": "'"$environment_name"' deploy created",
    "environment": "'"$environment_name"'",
    "auto_merge": false,
    "required_contexts": []
    }' | jq -r '.url') # Gets 'url' field from the response

  if [[ "$deploy_url" == "null" ]]; then
    echo "Failed to create Github deployment"
    exit 1
  else
    # Need to be shared between steps
    echo "DEPLOY_STATUSES_URL=$deploy_url/statuses" >> $GITHUB_ENV
    echo "Github deployment created: $deploy_url"
    exit 0
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

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN not set"
    exit 1
  fi

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

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN not set"
    exit 1
  fi

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

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN not set"
    exit 1
  fi

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

# Sets Github deploy status as "inactive"
#
# Input:
# - 1. ID of the deploy to have the status updated.
# - eg: $ gh_deploy_deactivate staging
#
# Required environment variables:
# - GITHUB_TOKEN        - Github user token with deploy rights.
# - DEPLOY_STATUSES_URL - URL for Github deploy statuses. Set by "gh_deploy_create".
#
# Required system tools:
# - curl
#
gh_deploy_deactivate() {
  deploy_id=$1

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN not set"
    exit 1
  fi

  curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.ant-man-preview+json" \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/deployments/${deploy_id}/statuses \
    -d '{ "state": "inactive" }'
}

# Gets list of Github repository deployments.
#
# Input:
# - 1. Environment (optional).
# - eg: $ gh_deploy_list
# - eg: $ gh_deploy_list review-app-156
#
# Required environment variables:
# - GITHUB_REPOSITORY - Set by default by Github. Formatted as "org/repo".
#
# Required system tools:
# - curl
#
gh_deploy_list() {
  environment=$1
  url="https://api.github.com/repos/${GITHUB_REPOSITORY}/deployments"
  # Filters by environment if provided.
  if [ -n $environment ]; then
    url="${url}?environment=${environment}"
  fi
  curl -X GET $url
}

# Deactivates Dangling deploys
#
# This function checks all the review app active deploys and deactivates them if
# the branch associated to the deploy has no open PRs.
#
# Input:
# 1. Environment. Deactivates dangling deploys only for the given environment.
# - eg: $ gh_deactivate_dangling
# - eg: $ gh_deactivate_dangling review-app-156
#
# Required environment variables:
# - GITHUB_REPOSITORY - Set by default by Github. Formatted as "org/repo".
#
# Required system tools:
# - curl
# - jq
#
gh_deploy_deactivate_dangling() {
  environment=$1
  if [ -n $environment ]; then
    deploy_list_command="gh_deploy_list $environment"
  else
    deploy_list_command="gh_deploy_list"
  fi

  # Iterates over all the deploys and gets their id, environment and references.
  # Format: "id@environment@reference".
  for deploy in $(eval $deploy_list_command |  jq -r '.[] | (.id|tostring) + "@" + .environment + "@" + .ref'); do
    # Parses id, environment and reference into separate variables.
    # '@' is used as separator for the splitting.
    IFS='@' read deploy_id deploy_environment deploy_ref <<< $deploy
    # We only want to deactivate Review Apps.
    if [[ $deploy_environment != "staging" && $deploy_environment != "production" ]]; then
      # Extracts Organization name from "org/repo".
      IFS='/' read -r org repo <<< $GITHUB_REPOSITORY
      # Number of open Pull Requests belonging to the branch.
      # We assume "deploy_ref" is a branch as our GH deploys use branch as ref.
      open_prs=$(curl "https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls?state=open&head=${org}:${deploy_ref}" | jq '. | length')
      # If there are no open PRs from the branch we can safely deactivate this branch deploys.
      if [[ $open_prs -eq 0 ]]; then
        # Gets most recent status for the deploy.
        deploy_status=$(curl https://api.github.com/repos/${GITHUB_REPOSITORY}/deployments/$deploy_id/statuses | jq -r '.[0].state')
        if [[ $deploy_status != "inactive" ]]; then
          echo "Deactivating $deploy_environment deployment $deploy_id for branch $deploy_ref"
          gh_deploy_deactivate $deploy_id
        fi
      fi
    fi
  done
}

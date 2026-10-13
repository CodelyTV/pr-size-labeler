#!/usr/bin/env bash

github_actions::get_pr_number() {
  local -r pr_number="${1:-}"

  if [ -n "$pr_number" ]; then
    if [[ ! "$pr_number" =~ ^[0-9]+$ ]]; then
      echoerr "Invalid PR number: $pr_number"
      return 1
    fi

    echo "$pr_number"
    return 0
  fi

  local -r pull_request_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

  if [[ "$pull_request_number" != "null" ]]; then
    echo "$pull_request_number"
  else
    echoerr "Not a pull request event, set pr_number input to label a PR from other events"
    return 1
  fi
}

#!/usr/bin/env bash

github_actions::get_pr_number() {
  local -r pull_request_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

  if [[ "$pull_request_number" != "null" ]]; then
    echo "$pull_request_number"
  else
    echo "Not a pull request event"
    exit 1
  fi
}

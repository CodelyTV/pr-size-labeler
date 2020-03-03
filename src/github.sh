#!/usr/bin/env bash

GITHUB_API_URI="https://api.github.com"
GITHUB_API_HEADER="Accept: application/vnd.github.v3+json"

github::calculate_total_modifications() {
  local -r body=$(curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/pulls/$1")

  local -r additions=$(echo "$body" | jq '.additions')
  local -r deletions=$(echo "$body" | jq '.deletions')

  echo "$additions + $deletions" | bc
}

github::add_label_to_pr() {
  local -r pr_number=$1
  local -r label_to_add=$2

  curl -sSL \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "$GITHUB_API_HEADER" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"labels\":[\"$label_to_add\"]}" \
    "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/issues/$pr_number/labels"
}

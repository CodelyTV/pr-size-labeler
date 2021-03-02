#!/usr/bin/env bash

GITHUB_API_URI="https://$PR_SIZE_LABELER_API"
GITHUB_API_HEADER="Accept: application/vnd.github.v3+json"

github::calculate_total_modifications() {
  local -r body=$(curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/pulls/$1")

  local -r additions=$(echo "$body" | jq '.additions')
  local -r deletions=$(echo "$body" | jq '.deletions')

  echo $((additions + deletions))
}

github::add_label_to_pr() {
  local -r pr_number=$1
  local -r label_to_add=$2

  local -r body=$(curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/pulls/$1")
  local labels=$(echo "$body" | jq .labels | jq -r ".[] | .name" | grep -v "size/")
  labels=$(printf "%s\n%s" "$labels" "$label_to_add")
  local -r comma_separated_labels=$(github::format_labels "$labels")

  log::message "Final labels: $comma_separated_labels"

  curl -sSL \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "$GITHUB_API_HEADER" \
    -X PATCH \
    -H "Content-Type: application/json" \
    -d "{\"labels\":[$comma_separated_labels]}" \
    "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/issues/$pr_number"
}

github::format_labels() {
  SAVEIFS=$IFS
  IFS=$'\n'
  local -r labels=($@)
  IFS=$SAVEIFS
  quoted_labels=()

  for ((i = 0; i < ${#labels[@]}; i++)); do
    #    echo "Label $i: ${labels[$i]}"
    label="${labels[$i]}"
    quoted_labels+=("$(str::quote "$label")")
  done

  coll::join_by "," "${quoted_labels[@]/#/}"
}

github::comment() {
  local -r comment=$1

  curl -sSL \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "$GITHUB_API_HEADER" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"body\":\"$comment\"}" \
    "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/issues/$pr_number/comments"
}

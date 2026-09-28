#!/usr/bin/env bash

GITHUB_API_HEADER="Accept: application/vnd.github.v3+json"

github::curl() {
  curl -fsSL "$@" || {
    echoerr "GitHub API request failed. If access was denied, add this to the job in your GitHub Actions workflow:"
    echoerr "  permissions:"
    echoerr "    pull-requests: write"
    echoerr "For pull requests from forks, use pull_request_target to get a writable token."
    return 1
  }
}

github::calculate_total_modifications() {
  local -r pr_number="${1}"
  local -r files_to_ignore="${2}"
  local -r ignore_line_deletions="${3}"
  local -r ignore_file_deletions="${4}"

  local additions=0
  local deletions=0

  if [ -z "$files_to_ignore" ] && [ "$ignore_file_deletions" != "true" ]; then
    local body
    body=$(github::curl -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/pulls/$pr_number") || return 1

    additions=$(echo "$body" | jq '.additions')

    if [ "$ignore_line_deletions" != "true" ]; then
      ((deletions += $(echo "$body" | jq '.deletions')))
    fi
  else
    local files
    files=$(github::get_pr_files "$pr_number") || return 1
    for file in $files; do
      filename=$(jq::base64 '.filename')
      status=$(jq::base64 '.status')
      ignore=false

      if [[ ( "$ignore_file_deletions" == "true" || "$ignore_line_deletions" == "true" ) && "$status" == "removed" ]]; then
        continue
      fi

      for pattern in $files_to_ignore; do
        if [[ $filename == $pattern ]]; then
          ignore=true
          break
        fi
      done

      if [ "$ignore" = false ]; then
        ((additions += $(jq::base64 '.additions')))

        if [ "$ignore_line_deletions" != "true" ]; then
          ((deletions += $(jq::base64 '.deletions')))
        fi
      fi
    done
  fi

  echo $((additions + deletions))
}

# Prints each file of the PR as a base64 encoded JSON object, one per line
github::get_pr_files() {
  local -r pr_number="${1}"
  local -r per_page=100
  local page=1
  local body

  # 100 is the maximum page size of the API, so a shorter page is the last one
  while true; do
    body=$(github::curl -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/pulls/$pr_number/files?per_page=$per_page&page=$page") || return 1

    # A non-array body means the request failed, so stop instead of looping forever
    if [ "$(echo "$body" | jq -r type 2>/dev/null)" != "array" ]; then
      break
    fi

    echo "$body" | jq -r '.[] | @base64'

    if [ "$(echo "$body" | jq length)" -lt "$per_page" ]; then
      break
    fi

    page=$((page + 1))
  done
}

github::has_label() {
  local -r pr_number="${1}"
  local -r label_to_check="${2}"

  local body
  body=$(github::curl -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number/labels") || return 2
  for label in $(echo "$body" | jq -r '.[] | @base64'); do
    if [ "$(echo ${label} | base64 -d | jq -r '.name')" = "$label_to_check" ]; then
      return 0
    fi
  done
  return 1
}

github::add_label_to_pr() {
  local -r pr_number="${1}"
  local -r label_to_add="${2}"
  local -r xs_label="${3}"
  local -r s_label="${4}"
  local -r m_label="${5}"
  local -r l_label="${6}"
  local -r xl_label="${7}"

  local body
  body=$(github::curl -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/pulls/$pr_number") || return 1
  local stale_labels
  stale_labels=$(github::find_stale_size_labels "$body" "$label_to_add" "$xs_label" "$s_label" "$m_label" "$l_label" "$xl_label") || return 1

  log::message "Adding size label: $label_to_add"
  github::add_label "$pr_number" "$label_to_add" || return 1

  if [ -z "$stale_labels" ]; then
    return 0
  fi

  local stale_label
  while IFS= read -r stale_label; do
    log::message "Removing size label: $stale_label"
    github::remove_label "$pr_number" "$stale_label" || return 1
  done <<< "$stale_labels"
}

github::find_stale_size_labels() {
  local -r body="$1"
  local -r current_label="$2"
  local -r xs_label="$3"
  local -r s_label="$4"
  local -r m_label="$5"
  local -r l_label="$6"
  local -r xl_label="$7"

  echo "$body" | jq -r \
    --arg current "$current_label" \
    --arg xs "$xs_label" --arg s "$s_label" --arg m "$m_label" --arg l "$l_label" --arg xl "$xl_label" \
    '.labels[].name | select(. != $current and (. == $xs or . == $s or . == $m or . == $l or . == $xl))'
}

github::add_label() {
  local -r pr_number="$1"
  local -r label="$2"
  local label_json
  label_json=$(jq -nc --arg name "$label" '{labels: [$name]}') || return 1

  github::curl \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "$GITHUB_API_HEADER" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "$label_json" \
    "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number/labels" >/dev/null || return 1
}

github::remove_label() {
  local -r pr_number="$1"
  local -r label="$2"
  local encoded_label
  encoded_label=$(jq -nr --arg name "$label" '$name | @uri') || return 1

  github::curl \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "$GITHUB_API_HEADER" \
    -X DELETE \
    "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number/labels/$encoded_label" >/dev/null || return 1
}

github::comment() {
  local -r comment="$1"

  github::curl \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "$GITHUB_API_HEADER" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"body\":\"$comment\"}" \
    "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number/comments"
}

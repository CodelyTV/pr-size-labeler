#!/usr/bin/env bash

GITHUB_API_HEADER="Accept: application/vnd.github.v3+json"

github::calculate_total_modifications() {
  local -r pr_number="${1}"
  local -r files_to_ignore="${2}"
  local -r ignore_line_deletions="${3}"
  local -r ignore_file_deletions="${4}"

  local additions=0
  local deletions=0

  if [ -z "$files_to_ignore" ] && [ "$ignore_file_deletions" != "true" ]; then
    local -r body=$(curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/pulls/$pr_number")

    additions=$(echo "$body" | jq '.additions')

    if [ "$ignore_line_deletions" != "true" ]; then
      ((deletions += $(echo "$body" | jq '.deletions')))
    fi
  else
    # NOTE: this code is not resilient to changes w/ > 100 files as we're not paginating
    local -r body=$(curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/pulls/$pr_number/files?per_page=100")

    for file in $(echo "$body" | jq -r '.[] | @base64'); do
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

github::has_label() {
  local -r pr_number="${1}"
  local -r label_to_check="${2}"

  local -r body=$(curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number/labels")
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

  local -r body=$(curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/pulls/$pr_number")
  local labels=$(echo "$body" | jq .labels | jq -r ".[] | .name" | grep -w -e "$xs_label" -e "$s_label" -e "$m_label" -e "$l_label" -e "$xl_label" -v)
  labels=$(printf "%s\n%s" "$labels" "$label_to_add")
  local -r comma_separated_labels=$(github::format_labels "$labels")

  log::message "Final labels: $comma_separated_labels"

  curl -sSL \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "$GITHUB_API_HEADER" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"labels\":[$comma_separated_labels]}" \
    "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number/labels" >/dev/null
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
  local -r comment="$1"

  curl -sSL \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "$GITHUB_API_HEADER" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"body\":\"$comment\"}" \
    "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number/comments"
}

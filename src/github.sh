#!/usr/bin/env bash

GITHUB_API_HEADER="Accept: application/vnd.github.v3+json"

github::calculate_total_modifications() {
  local -r pr_number="${1}"
  local -r files_to_ignore="${2}"
  local -r ignore_line_deletions="${3}"
  local -r changed_file_weight="${4}"

  local additions=0
  local deletions=0

  if [ -z "$files_to_ignore" ]; then
    local -r body=$(curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/pulls/$pr_number")

    additions=$(echo "$body" | jq '.additions')

    if [ "$ignore_line_deletions" != "true" ]; then
      ((deletions += $(echo "$body" | jq '.deletions')))
    fi
    changed_files=$(echo "$body" | jq '.changed_files')
    echo $((additions + deletions + (changed_files * changed_file_weight)))
  else
    local -r body=$(curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER" "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/pulls/$pr_number/files?per_page=100")
    fileCount=0
    for file in $(echo "$body" | jq -r '.[] | @base64'); do
    fileCount=$((fileCount+1))
      filename=$(jq::base64 '.filename')
      ignore=false

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
  echo $((additions + deletions + (changed_files * changed_file_weight)))
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
    -X PATCH \
    -H "Content-Type: application/json" \
    -d "{\"labels\":[$comma_separated_labels]}" \
    "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number" >/dev/null
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
    -d "{\"body\":$comment}" \
    "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number/comments"
}

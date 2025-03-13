#!/usr/bin/env bash

# --- Existing Functions ---

labeler::label() {
  local -r xs_label="${1}"
  local -r s_label="${3}"
  local -r m_label="${5}"
  local -r l_label="${7}"
  local -r xl_label="${9}"
  local -r fail_if_xl="${10}"
  local -r message_if_xl="${11}"
  local -r files_to_ignore="${12}"
  local -r ignore_line_deletions="${13}"
  local -r ignore_file_deletions="${14}"

  local -r pr_number=$(github_actions::get_pr_number)
  local -r total_modifications=$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}" "$ignore_line_deletions" "$ignore_file_deletions")

  log::message "Total modifications (additions + deletions): $total_modifications"
  log::message "Ignoring files (if present): $files_to_ignore"

  local -r label_to_add=$(labeler::label_for "$total_modifications" "$@")

  log::message "Labeling pull request with size label: $label_to_add"

  github::add_label_to_pr "$pr_number" "$label_to_add" "$xs_label" "$s_label" "$m_label" "$l_label" "$xl_label"

  # If the PR size label is "xl", handle the extra messages or failure as before.
  if [ "$label_to_add" == "$xl_label" ]; then
    if [ -n "$message_if_xl" ] && ! github::has_label "$pr_number" "$label_to_add"; then
      github::comment "$message_if_xl"
    fi

    if [ "$fail_if_xl" == "true" ]; then
      echoerr "PR is xl, please, shorten this!"
      exit 1
    fi
  fi

  # ---- Add Language Labeling ----
  log::message "Detecting languages in changed files..."
  labeler::add_language_labels "$pr_number"
}

labeler::label_for() {
  local -r total_modifications=${1}
  local -r xs_label="${2}"
  local -r xs_max_size=${3}
  local -r s_label="${4}"
  local -r s_max_size=${5}
  local -r m_label="${6}"
  local -r m_max_size=${7}
  local -r l_label="${8}"
  local -r l_max_size=${9}
  local -r xl_label="${10}"

  if [ "$total_modifications" -lt "$xs_max_size" ]; then
    label="$xs_label"
  elif [ "$total_modifications" -lt "$s_max_size" ]; then
    label="$s_label"
  elif [ "$total_modifications" -lt "$m_max_size" ]; then
    label="$m_label"
  elif [ "$total_modifications" -lt "$l_max_size" ]; then
    label="$l_label"
  else
    label="$xl_label"
  fi

  echo "$label"
}

# --- New Functions for Language Labeling ---

# This helper adds a label to the PR.
# If you already have a similar function in your repository, you can replace this.
github::add_label() {
  local pr_number="$1"
  local label="$2"
  curl -s -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{\"labels\": [\"${label}\"]}" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${pr_number}/labels" > /dev/null
}

# This function fetches changed files, determines languages from file extensions,
# and adds corresponding language labels (prefixed with "pr: lang/").
labeler::add_language_labels() {
  local pr_number="$1"

  # Fetch changed files for the PR.
  local files_json
  files_json=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls/${pr_number}/files")

  # Use an associative array to avoid duplicate labels.
  declare -A languages

  # Loop over each file and determine language based on file extension.
  for file in $(echo "$files_json" | jq -r '.[].filename'); do
    ext="${file##*.}"
    case "$ext" in
      js|jsx)
        languages["pr: lang/javascript"]=1
        ;;
      ts|tsx)
        languages["pr: lang/typescript"]=1
        ;;
      py)
        languages["pr: lang/python"]=1
        ;;
      rb)
        languages["pr: lang/ruby"]=1
        ;;
      java)
        languages["pr: lang/java"]=1
        ;;
      go)
        languages["pr: lang/go"]=1
        ;;
      cs)
        languages["pr: lang/csharp"]=1
        ;;
      cpp)
        languages["pr: lang/cpp"]=1
        ;;
      c)
        languages["pr: lang/c"]=1
        ;;
      php)
        languages["pr: lang/php"]=1
        ;;
      *)
        # Ignore other extensions or add a generic label if desired.
        ;;
    esac
  done

  # Add each detected language label to the PR.
  for lang_label in "${!languages[@]}"; do
    log::message "Adding language label: ${lang_label}"
    github::add_label "$pr_number" "$lang_label"
  done
}
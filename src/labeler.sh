#!/usr/bin/env bash

labeler::label() {
  local -r xs_label="${1}"
  local -r s_label="${3}"
  local -r m_label="${5}"
  local -r l_label="${7}"
  local -r xl_label="${9}"
  local -r fail_if_xl="${10}"
  local -r message_if_xl="${11}"
  local -r files_to_ignore="${12}"

  local -r pr_number=$(github_actions::get_pr_number)
  local -r total_modifications=$(github::calculate_total_modifications "$pr_number" "$files_to_ignore")

  log::message "Total modifications (additions + deletions): $total_modifications"
  log::message "Ignoring files (if present): $files_to_ignore"

  local -r label_to_add=$(labeler::label_for "$total_modifications" "$@")

  log::message "Labeling pull request with $label_to_add"

  github::add_label_to_pr "$pr_number" "$label_to_add" "$xs_label" "$s_label" "$m_label" "$l_label" "$xl_label"

  if [ "$label_to_add" == "$xl_label" ]; then
    if [ -n "$message_if_xl" ]; then
      github::comment "$message_if_xl"
    fi

    if [ "$fail_if_xl" == "true" ]; then
      echoerr "Pr is xl, please, short this!!"
      exit 1
    fi
  fi
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

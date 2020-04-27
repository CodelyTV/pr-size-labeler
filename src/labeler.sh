#!/usr/bin/env bash

labeler::label() {
  local -r fail_if_xl="$5"
  local -r message_if_xl="$6"

  local -r pr_number=$(github_actions::get_pr_number)
  local -r total_modifications=$(github::calculate_total_modifications "$pr_number")

  log::message "Total modifications: $total_modifications"

  local -r label_to_add=$(labeler::label_for "$total_modifications" "$@")

  log::message "Labeling pull request with $label_to_add"

  github::add_label_to_pr "$pr_number" "$label_to_add"

  if [ "$label_to_add" == "size/xl" ]; then
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
  local -r total_modifications="$1"
  local -r xs_max_size="$2"
  local -r s_max_size="$3"
  local -r m_max_size="$4"
  local -r l_max_size="$5"

  if [ "$total_modifications" -lt "$xs_max_size" ]; then
    label="size/xs"
  elif [ "$total_modifications" -lt "$s_max_size" ]; then
    label="size/s"
  elif [ "$total_modifications" -lt "$m_max_size" ]; then
    label="size/m"
  elif [ "$total_modifications" -lt "$l_max_size" ]; then
    label="size/l"
  else
    label="size/xl"
  fi

  echo "$label"
}

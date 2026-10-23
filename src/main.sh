#!/usr/bin/env bash

source "$PR_SIZE_LABELER_HOME/src/ensure.sh"
source "$PR_SIZE_LABELER_HOME/src/github.sh"
source "$PR_SIZE_LABELER_HOME/src/github_actions.sh"
source "$PR_SIZE_LABELER_HOME/src/labeler.sh"
source "$PR_SIZE_LABELER_HOME/src/misc.sh"

##? Adds a size label to a GitHub Pull Request
##?
##? Usage:
##?   main.sh --github_token=<token> --xs_label=<label> --xs_max_size=<size> --s_label=<label> --s_max_size=<size> --m_label=<label> --m_max_size=<size> --l_label=<label> --l_max_size=<size> --xl_label=<label> --fail_if_xl=<false> --message_if_xl=<message> --github_api_url=<url> --files_to_ignore=<files> --ignore_line_deletions=<false> --ignore_file_deletions=<false>
main() {
  main::parse_args "$@"

  ensure::env_variable_exist "GITHUB_REPOSITORY"
  ensure::env_variable_exist "GITHUB_EVENT_PATH"

  export GITHUB_TOKEN="$github_token"
  export GITHUB_API_URL="$github_api_url"

  labeler::label \
    "$xs_label" \
    "$xs_max_size" \
    "$s_label" \
    "$s_max_size" \
    "$m_label" \
    "$m_max_size" \
    "$l_label" \
    "$l_max_size" \
    "$xl_label" \
    "$fail_if_xl" \
    "$message_if_xl" \
    "$files_to_ignore" \
    "$ignore_line_deletions" \
    "$ignore_file_deletions"

  exit $?
}

# Sets one global variable per --option=value, every option in the usage being required exactly once
main::parse_args() {
  local -r usage="$(grep "^##?" "$PR_SIZE_LABELER_HOME/src/main.sh" | cut -c 5-)"
  local -r options="$(echo "$usage" | grep -o -- '--[a-z_]*=' | sed 's/^--//; s/=$//')"
  local seen=' '
  local arg option

  for arg in "$@"; do
    option="${arg%%=*}"
    option="${option#--}"

    if [[ "$arg" != --*=* ]] || ! grep -qx -- "$option" <<< "$options" || [[ "$seen" == *" $option "* ]]; then
      main::invalid_args "$usage"
    fi

    printf -v "$option" '%s' "${arg#*=}"
    seen+="$option "
  done

  for option in $options; do
    if [[ "$seen" != *" $option "* ]]; then
      main::invalid_args "$usage"
    fi
  done
}

main::invalid_args() {
  echoerr "Invalid arguments."
  echoerr
  echoerr "$1"
  exit 1
}

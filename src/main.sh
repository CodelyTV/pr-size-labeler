#!/usr/bin/env bash

source "$PR_SIZE_LABELER_HOME/src/ensure.sh"
source "$PR_SIZE_LABELER_HOME/src/github.sh"
source "$PR_SIZE_LABELER_HOME/src/github_actions.sh"
source "$PR_SIZE_LABELER_HOME/src/labeler.sh"
source "$PR_SIZE_LABELER_HOME/src/misc.sh"

main() {
  ensure::env_variable_exist "GITHUB_REPOSITORY"
  ensure::env_variable_exist "GITHUB_EVENT_PATH"
  ensure::total_args 7 "$@"

  if [ -z "$GITHUB_API_URL" ]; then
    log::message "GITHUB_API_URL not set, using default: https://api.github.com"
    export GITHUB_API_URL="https://api.github.com"
  fi

  export GITHUB_TOKEN="$1"

  labeler::label "$2" "$3" "$4" "$5" "$6" "$7"

  exit $?
}

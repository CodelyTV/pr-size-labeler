#!/bin/bash

function set_up() {
  source ./src/misc.sh
  source ./src/github.sh
}

function test_should_ignore_files_with_glob() {
  local -r pr_number=123
  local -r files_to_ignore=("*.lock" ".editorconfig")
  mock curl cat ./tests/fixtures/test_should_ignore_files_with_regex_response

  assert_match_snapshot "$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}")"
}

#!/bin/bash

function set_up() {
  source ./src/misc.sh
  source ./src/github_actions.sh

  GITHUB_EVENT_PATH=$(mktemp)
}

function tear_down() {
  rm -f "$GITHUB_EVENT_PATH"
}

function test_should_read_pr_number_from_pull_request_event() {
  echo '{"pull_request": {"number": 42}}' > "$GITHUB_EVENT_PATH"

  assert_equals 42 "$(github_actions::get_pr_number)"
}

function test_should_prefer_given_pr_number() {
  echo '{"pull_request": {"number": 42}}' > "$GITHUB_EVENT_PATH"

  assert_equals 7 "$(github_actions::get_pr_number 7)"
}

function test_should_use_given_pr_number_for_other_events() {
  echo '{"schedule": "*/5 * * * *"}' > "$GITHUB_EVENT_PATH"

  assert_equals 7 "$(github_actions::get_pr_number 7)"
}

function test_should_fail_for_other_events_without_pr_number() {
  echo '{"schedule": "*/5 * * * *"}' > "$GITHUB_EVENT_PATH"

  if output=$(github_actions::get_pr_number 2>/dev/null); then status=0; else status=$?; fi

  assert_equals 1 "$status"
  assert_equals '' "$output"
}

function test_should_reject_invalid_pr_number() {
  echo '{"pull_request": {"number": 42}}' > "$GITHUB_EVENT_PATH"

  if output=$(github_actions::get_pr_number '12a' 2>/dev/null); then status=0; else status=$?; fi

  assert_equals 1 "$status"
  assert_equals '' "$output"
}

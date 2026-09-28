#!/bin/bash

function set_up() {
  source ./src/misc.sh
  source ./src/github.sh
  label_requests=''
}

function tear_down() {
  if [ -n "$label_requests" ]; then
    rm -f "$label_requests"
  fi
}

function mock_pull_request_api() {
  cat ./tests/fixtures/pull_request_api
}

function mock_pull_request_files_api() {
  cat ./tests/fixtures/pull_request_files_api
}

function mock_not_found_response() {
  echo 'curl: (22) HTTP 403' >&2
  return 22
}

function mock_label_write_denied() {
  case "$*" in
    *'-X POST'*) mock_not_found_response ;;
    *) mock_pull_request_api ;;
  esac
}

function mock_label_api() {
  case "$*" in
    *"/pulls/$pr_number") echo "$label_snapshot" ;;
    *'-X POST'*) echo "POST $*" >> "$label_requests" ;;
    *'-X DELETE'*) echo "DELETE $*" >> "$label_requests" ;;
    *) return 1 ;;
  esac
}

pr_number=123
files_to_ignore=''
ignore_line_deletions='false'
ignore_file_deletions='false'

function test_should_count_changes() {
  bashunit::mock curl mock_pull_request_api

  assert_equals 174 "$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}" "$ignore_line_deletions" "$ignore_file_deletions")"
}

function test_should_count_changes_ignore_line_deletions() {
  ignore_line_deletions='true'

  bashunit::mock curl mock_pull_request_api

  assert_equals 173 "$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}" "$ignore_line_deletions" "$ignore_file_deletions")"
}

# NOTE: when `files_to_ignore` or `ignore_file_deletions` is set, we have to invoke the PR files API and iterate each file
# one at at time. This is why the mock call is diffent in the subsequent test cases
function test_should_count_changes_ignore_file_deletions() {
  ignore_file_deletions='true'

  bashunit::mock curl mock_pull_request_files_api

  assert_equals 2779 "$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}" "$ignore_line_deletions" "$ignore_file_deletions")"
}

function test_should_ignore_files_with_glob() {
  files_to_ignore=("*.lock" ".editorconfig")

  bashunit::mock curl mock_pull_request_files_api

  assert_equals 517 "$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}" "$ignore_line_deletions" "$ignore_file_deletions")"
}

function test_should_ignore_files_with_glob_ignore_line_deletions() {
  files_to_ignore=("*.lock" ".editorconfig")
  ignore_line_deletions='true'

  bashunit::mock curl mock_pull_request_files_api

  assert_equals 224 "$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}" "$ignore_line_deletions" "$ignore_file_deletions")"
}

function test_should_ignore_files_with_glob_ignore_file_deletions() {
  files_to_ignore=("*.lock" ".editorconfig")
  ignore_file_deletions='true'

  bashunit::mock curl mock_pull_request_files_api

  assert_equals 394 "$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}" "$ignore_line_deletions" "$ignore_file_deletions")"
}

function test_should_count_changes_across_pages() {
  ignore_file_deletions='true'

  # Plain function instead of `bashunit::mock`, as the response has to differ per page:
  # a full page of 100 files with 2 changes each, then the fixture as last page
  function curl() {
    case "$*" in
      *"page=1") jq -n '[range(100) | {filename: "file-\(.)", status: "modified", additions: 1, deletions: 1}]' ;;
      *"page=2") cat ./tests/fixtures/pull_request_files_api ;;
    esac
  }

  assert_equals $((200 + 2779)) "$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}" "$ignore_line_deletions" "$ignore_file_deletions")"
}

function test_should_report_permission_error() {
  ignore_file_deletions='true'

  bashunit::mock curl mock_not_found_response

  local output status
  output=$(github::calculate_total_modifications "$pr_number" "${files_to_ignore[*]}" "$ignore_line_deletions" "$ignore_file_deletions" 2>&1)
  status=$?

  assert_equals 1 "$status"
  assert_contains 'pull-requests: write' "$output"
}

function test_should_report_permission_error_on_label_write() {
  bashunit::mock curl mock_label_write_denied

  local output status
  output=$(github::add_label_to_pr "$pr_number" 'size/xs' 'size/xs' 'size/s' 'size/m' 'size/l' 'size/xl' 2>&1)
  status=$?

  assert_equals 1 "$status"
  assert_contains 'pull-requests: write' "$output"
}

function test_should_preserve_labels_added_after_reading_the_pr() {
  label_requests=$(mktemp)
  # The snapshot cannot include labels added by another workflow after this read.
  label_snapshot='{"labels":[{"name":"size/old label"},{"name":"size/m"},{"name":"team/needs review"}]}'
  old_label='size/old label'
  bashunit::mock curl mock_label_api

  local output
  output=$(github::add_label_to_pr "$pr_number" 'size/"new"' 'size/xs' "$old_label" 'size/m' 'size/l' 'size/"new"')

  assert_contains 'Removing size label: size/old label' "$output"
  assert_contains 'Removing size label: size/m' "$output"
  assert_equals $'POST\nDELETE\nDELETE' "$(cut -d ' ' -f 1 "$label_requests")"
  assert_contains '{"labels":["size/\"new\""]}' "$(cat "$label_requests")"
  assert_contains '/labels/size%2Fold%20label' "$(cat "$label_requests")"
  assert_contains '/labels/size%2Fm' "$(cat "$label_requests")"
}

function test_should_not_remove_the_current_size_label() {
  label_requests=$(mktemp)
  label_snapshot='{"labels":[{"name":"size/xl"},{"name":"team/needs review"}]}'
  bashunit::mock curl mock_label_api

  github::add_label_to_pr "$pr_number" 'size/xl' 'size/xs' 'size/s' 'size/m' 'size/l' 'size/xl'

  assert_equals 'POST' "$(cut -d ' ' -f 1 "$label_requests")"
  assert_contains '{"labels":["size/xl"]}' "$(cat "$label_requests")"
}

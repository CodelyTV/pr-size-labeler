#!/bin/bash

function set_up() {
  source ./src/labeler.sh

  current_label=''
  total_modifications=1000
  label_lookup_count=0
  comment_count=0
  comment_message=''
  message_if_xl='Please split this PR'
  calculate_status=0
  # Written by the mock, as the caller captures its output in a subshell
  received_max_modifications=$(mktemp)
  label_lookup_status=0
  label_write_status=0
  comment_status=0
  log_messages=()
}

function tear_down() {
  rm -f "$received_max_modifications"
}

function github_actions::get_pr_number() {
  echo 123
}

function github::calculate_total_modifications() {
  [ "$calculate_status" -eq 0 ] || return 1
  echo "$5" > "$received_max_modifications"
  echo "$total_modifications"
}

function github::has_label() {
  label_lookup_count=$((label_lookup_count + 1))
  [ "$label_lookup_status" -eq 0 ] || return 2
  [ "$current_label" == "$2" ]
}

function github::add_label_to_pr() {
  [ "$label_write_status" -eq 0 ] || return 1
  current_label="$2"
}

function github::comment() {
  [ "$comment_status" -eq 0 ] || return 1
  comment_count=$((comment_count + 1))
  comment_message="$1"
}

function log::message() {
  log_messages+=("$*")
}

function label_pr() {
  labeler::label 'size/xs' 10 'size/s' 100 'size/m' 500 'size/l' 1000 'size/xl' false "$message_if_xl" '' false false
}

function test_should_comment_when_pr_first_becomes_xl() {
  current_label='size/l'

  label_pr

  assert_equals 'size/xl' "$current_label"
  assert_equals 1 "$label_lookup_count"
  assert_equals 1 "$comment_count"
  assert_equals "$message_if_xl" "$comment_message"
}

function test_should_not_comment_when_pr_remains_xl() {
  current_label='size/xl'

  label_pr

  assert_equals 'size/xl' "$current_label"
  assert_equals 1 "$label_lookup_count"
  assert_equals 0 "$comment_count"
}

function test_should_comment_when_pr_returns_to_xl() {
  current_label='size/xl'
  total_modifications=250

  label_pr
  assert_equals 'size/m' "$current_label"

  total_modifications=1000
  label_pr

  assert_equals 'size/xl' "$current_label"
  assert_equals 1 "$label_lookup_count"
  assert_equals 1 "$comment_count"
}

function test_should_skip_label_lookup_without_xl_message() {
  total_modifications=250
  label_pr

  message_if_xl=''
  total_modifications=1000
  label_pr

  assert_equals 0 "$label_lookup_count"
  assert_equals 0 "$comment_count"
}

function test_should_use_largest_size_cutoff_when_sizes_are_out_of_order() {
  total_modifications=1100

  labeler::label 'size/xs' 10 'size/s' 100 'size/m' 1200 'size/l' 1000 'size/xl' false '' '' false true

  assert_equals 1200 "$(cat "$received_max_modifications")"
  assert_equals 'size/m' "$current_label"
}

function test_should_log_exact_count_without_file_filtering() {
  total_modifications=1500

  label_pr

  assert_equals 'Counted modifications (additions + deletions): 1500' "${log_messages[0]}"
}

function test_should_log_lower_bound_when_file_count_reaches_cutoff() {
  labeler::label 'size/xs' 10 'size/s' 100 'size/m' 500 'size/l' 1000 'size/xl' false '' '' false true

  assert_equals 'Counted at least 1000 modifications (additions + deletions), largest size cutoff reached' "${log_messages[0]}"
}

function test_should_log_exact_file_count_below_cutoff() {
  total_modifications=999

  labeler::label 'size/xs' 10 'size/s' 100 'size/m' 500 'size/l' 1000 'size/xl' false '' '*.lock' false false

  assert_equals 'Counted modifications (additions + deletions): 999' "${log_messages[0]}"
}

function test_should_stop_when_pr_read_fails() {
  calculate_status=1

  if label_pr >/dev/null 2>&1; then status=0; else status=$?; fi

  assert_equals 1 "$status"
  assert_equals '' "$current_label"
}

function test_should_stop_when_label_write_fails() {
  label_write_status=1

  if label_pr >/dev/null 2>&1; then status=0; else status=$?; fi

  assert_equals 1 "$status"
  assert_equals '' "$current_label"
}

function test_should_stop_when_label_lookup_fails() {
  label_lookup_status=2

  if label_pr >/dev/null 2>&1; then status=0; else status=$?; fi

  assert_equals 1 "$status"
  assert_equals '' "$current_label"
}

function test_should_fail_when_comment_write_fails() {
  comment_status=1

  if label_pr >/dev/null 2>&1; then status=0; else status=$?; fi

  assert_equals 1 "$status"
}

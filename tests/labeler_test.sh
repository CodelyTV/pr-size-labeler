#!/bin/bash

function set_up() {
  source ./src/labeler.sh

  current_label=''
  total_modifications=1000
  label_lookup_count=0
  comment_count=0
  comment_message=''
  message_if_xl='Please split this PR'
}

function github_actions::get_pr_number() {
  echo 123
}

function github::calculate_total_modifications() {
  echo "$total_modifications"
}

function github::has_label() {
  label_lookup_count=$((label_lookup_count + 1))
  [ "$current_label" == "$2" ]
}

function github::add_label_to_pr() {
  current_label="$2"
}

function github::comment() {
  comment_count=$((comment_count + 1))
  comment_message="$1"
}

function log::message() {
  :
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

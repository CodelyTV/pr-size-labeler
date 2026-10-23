#!/bin/bash

function set_up() {
  PR_SIZE_LABELER_HOME=.
  source ./src/main.sh

  # Defined after sourcing, as main.sh sources the real labeler
  function labeler::label() {
    printf '%s|' "$@"
    printf '%s|%s\n' "$GITHUB_TOKEN" "$GITHUB_API_URL"
  }

  export GITHUB_REPOSITORY='owner/repo'
  export GITHUB_EVENT_PATH='/dev/null'
  args=(
    --github_token=token
    --github_api_url=https://api.github.com
    --xs_label=size/xs
    --xs_max_size=10
    --s_label=size/s
    --s_max_size=100
    --m_label=size/m
    --m_max_size=500
    --l_label=size/l
    --l_max_size=1000
    --xl_label=size/xl
    --fail_if_xl=false
    '--message_if_xl=Please split this PR'
    '--files_to_ignore=*.lock docs/*'
    --ignore_line_deletions=false
    --ignore_file_deletions=true
  )
}

function test_should_pass_arguments_to_labeler() {
  assert_equals \
    'size/xs|10|size/s|100|size/m|500|size/l|1000|size/xl|false|Please split this PR|*.lock docs/*|false|true|token|https://api.github.com' \
    "$(main "${args[@]}")"
}

function test_should_accept_arguments_in_any_order() {
  assert_equals "$(main "${args[@]}")" "$(main "${args[@]:8}" "${args[@]:0:8}")"
}

function test_should_keep_special_characters_in_values() {
  args[12]='--message_if_xl=a=b $HOME `id` "quoted"'

  assert_contains '|a=b $HOME `id` "quoted"|' "$(main "${args[@]}")"
}

function test_should_accept_empty_values() {
  args[13]='--files_to_ignore='

  assert_contains '|Please split this PR||false|' "$(main "${args[@]}")"
}

function test_should_fail_when_an_argument_is_missing() {
  assert_general_error "$(main "${args[@]:1}" 2>/dev/null)"
}

function test_should_fail_on_an_unknown_argument() {
  assert_general_error "$(main "${args[@]}" --unknown=value 2>/dev/null)"
}

function test_should_fail_on_a_duplicated_argument() {
  assert_general_error "$(main "${args[@]}" --xs_label=other 2>/dev/null)"
}

function test_should_fail_on_an_argument_without_value() {
  assert_general_error "$(main "${args[@]}" extra 2>/dev/null)"
}

function test_should_print_usage_on_invalid_arguments() {
  assert_contains 'Usage:' "$(main "${args[@]:1}" 2>&1)"
}

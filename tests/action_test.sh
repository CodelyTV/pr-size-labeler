#!/bin/bash

# native/action.yml duplicates the Docker action's inputs and arguments, so check they stay in sync

function inputs_block() {
  sed -n '/^inputs:/,/^runs:/p' "$1"
}

function input_names() {
  inputs_block ./action.yml | grep -o '^  [A-Za-z_]*:' | tr -d ' :'
}

function test_should_declare_the_same_inputs() {
  assert_equals "$(inputs_block ./action.yml)" "$(inputs_block ./native/action.yml)"
}

function test_should_pass_the_same_arguments() {
  local -r docker_args=$(grep -o -- '- --[a-z_]*=' ./action.yml | cut -c 3-)
  local -r native_args=$(grep -o -- '"--[a-z_]*=' ./native/action.yml | cut -c 2-)

  assert_equals "$docker_args" "$native_args"
}

function test_should_pass_every_input_through_env() {
  local name

  for name in $(input_names); do
    assert_contains "INPUT_${name^^}: \${{ inputs.$name }}" "$(cat ./native/action.yml)"
  done
}

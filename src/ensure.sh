#!/usr/bin/env bash

ensure::env_variable_exist() {
  if [[ -z "${!1}" ]]; then
    echoerr "The env variable $1 is required."
    exit 1
  fi
}

ensure::total_args() {
  local -r received_args=$(( $# - 1 ))
  local -r expected_args=$1

  if ((received_args != expected_args)); then
    echoerr "Illegal number of parameters, $expected_args expected but $received_args found"
    exit 1
  fi
}

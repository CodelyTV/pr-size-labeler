#!/usr/bin/env bash

ensure::env_variable_exist() {
  if [[ -z "${!1}" ]]; then
    echoerr "The env variable $1 is required."
    exit 1
  fi
}

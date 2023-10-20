#!/usr/bin/env bash

echoerr() {
  echo "$@" 1>&2
}

log::message() {
  echo "$@"
}

coll::join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

coll::map() {
  local -r fn="$1"

  for x in $(cat); do
    "$fn" "$x"
  done
}

str::quote() {
  echo "\"$1\""
}

jq::base64() {
  echo "$file" | base64 -d | jq -r "$1"
}

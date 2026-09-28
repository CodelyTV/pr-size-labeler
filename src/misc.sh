#!/usr/bin/env bash

echoerr() {
  echo "$@" 1>&2
}

log::message() {
  echo "$@"
}

coll::map() {
  local -r fn="$1"

  for x in $(cat); do
    "$fn" "$x"
  done
}

jq::base64() {
  echo "$file" | base64 -d | jq -r "$1"
}

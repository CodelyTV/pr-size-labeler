#!/usr/bin/env bash

github_actions::get_pr_number() {
  jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH"
}

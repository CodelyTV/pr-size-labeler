#!/usr/bin/env bash
set -euo pipefail

PR_SIZE_LABELER_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PR_SIZE_LABELER_API="api.github.com"

if [ "$PR_SIZE_LABELER_HOME" == "/" ]; then
  PR_SIZE_LABELER_HOME=""
fi

if [ ! -z "$8" ]; then
    PR_SIZE_LABELER_API=$8
fi

export PR_SIZE_LABELER_HOME
export PR_SIZE_LABELER_API

bash --version

source "$PR_SIZE_LABELER_HOME/src/main.sh"

main "$@"

exit $?

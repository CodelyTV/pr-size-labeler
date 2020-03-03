#!/usr/bin/env bash
set -euo pipefail

PR_SIZE_LABELER_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if [ "$PR_SIZE_LABELER_HOME" == "/" ]; then
  PR_SIZE_LABELER_HOME=""
fi

export PR_SIZE_LABELER_HOME

source "$PR_SIZE_LABELER_HOME/src/main.sh"

main "$@"

exit $?

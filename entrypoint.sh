#!/usr/bin/env bash
set -euo pipefail

PR_SIZE_LABELER_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if [ "$PR_SIZE_LABELER_HOME" == "/" ]; then
  PR_SIZE_LABELER_HOME=""
fi

export PR_SIZE_LABELER_HOME

bash --version

source "$PR_SIZE_LABELER_HOME/src/main.sh"

for a in "${@}"; do
  arg=$(echo "$a" | tr '\n' ' ' | xargs echo | sed "s/'//g"| sed "s/’//g")
  sanitizedArgs+=("$arg")
done

main "${sanitizedArgs[@]}"

exit $?

#!/usr/bin/env bash

LABELER_LOG_FILE=${LABELER_LOG_FILE:-$HOME/labeler.log}

log::file() {
	local -r log_name="$1"
	local -r current_date=$(date "+%Y-%m-%d %H:%M:%S")

	touch "$LABELER_LOG_FILE"
	echo "----- $current_date - $log_name -----" >>"$LABELER_LOG_FILE"

	while IFS= read -r log_message; do
		echo "$log_message" >>"$LABELER_LOG_FILE"
	done

	echo "" >>"$LABELER_LOG_FILE"
}

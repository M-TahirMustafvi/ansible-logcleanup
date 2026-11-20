#!/usr/bin/env bash
# Managed by Ansible (role: logcleanup). Do not edit by hand.
set -euo pipefail

LOG_DIR="${1:?usage: logcleanup.sh DIR PATTERN DAYS}"
PATTERN="${2:?usage: logcleanup.sh DIR PATTERN DAYS}"
RETENTION_DAYS="${3:?usage: logcleanup.sh DIR PATTERN DAYS}"

if [[ "$LOG_DIR" == "/" ]]; then
    echo "logcleanup: refusing to clean /" >&2
    exit 1
fi

if [[ ! -d "$LOG_DIR" ]]; then
    echo "logcleanup: directory not found: $LOG_DIR" >&2
    exit 1
fi

if ! [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]] || (( RETENTION_DAYS <= 0 )); then
    echo "logcleanup: retention must be a positive whole number, got: $RETENTION_DAYS" >&2
    exit 1
fi

deleted=$(find "$LOG_DIR" -type f -name "$PATTERN" \
    -mtime +"$RETENTION_DAYS" -print -delete | wc -l)
logger -t logcleanup "removed ${deleted} file(s) older than ${RETENTION_DAYS} days from ${LOG_DIR}"

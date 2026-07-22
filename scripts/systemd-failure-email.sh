#!/bin/bash

SERVICE="$1"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

REPORT_CONTENT="$("$SCRIPT_DIR/collect-service-info.sh" "$SERVICE")"

echo "$REPORT_CONTENT"

"$SCRIPT_DIR/send-email.sh" "$SERVICE" "$REPORT_CONTENT"
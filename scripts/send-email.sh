#!/bin/bash

SERVICE="$1"
REPORT="$2"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/load-env.sh"

IFS=',' read -ra RECIPIENTS <<< "$SMTP_TO"

EMAIL_FILE="$(mktemp)"

{
    TO_HEADER=""

    for TO in "${RECIPIENTS[@]}"; do
        TO="${TO// /}"

        if [ -z "$TO_HEADER" ]; then
            TO_HEADER="$TO"
        else
            TO_HEADER="$TO_HEADER, $TO"
        fi
    done

    echo "To: $TO_HEADER"

    echo "From: $SMTP_FROM"
    echo "Subject: [ALERT] Blockchain Node Failure - $SERVICE"
    echo "Content-Type: text/plain; charset=UTF-8"
    echo

    echo "$REPORT"

} > "$EMAIL_FILE"

msmtp \
    --host="$SMTP_HOST" \
    --port="$SMTP_PORT" \
    --auth=on \
    --tls="$SMTP_TLS" \
    --tls-starttls="$SMTP_STARTTLS" \
    --user="$SMTP_USERNAME" \
    --passwordeval="printf '%s' '$SMTP_PASSWORD'" \
    --from="$SMTP_FROM" \
    "${RECIPIENTS[@]}" < "$EMAIL_FILE"

rm -f "$EMAIL_FILE"
#!/bin/bash

SERVICE="$1"

echo "======================================"
echo "BLOCKCHAIN NODE FAILURE"
echo "======================================"
echo "Service : $SERVICE"
echo "Hostname: $(hostname)"
echo "Time    : $(date)"
echo

systemctl status "$SERVICE" --no-pager

echo
echo "========== LAST 30 LOGS =========="

journalctl -u "$SERVICE" -n 30 --no-pager
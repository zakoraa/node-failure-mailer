#!/bin/bash

set -e

PROJECT_DIR="$(pwd)"
CURRENT_USER="$(whoami)"

echo "Installing systemd services..."
echo "Project directory : $PROJECT_DIR"
echo "Current user      : $CURRENT_USER"

sudo sed \
    -e "s|__PROJECT_DIR__|$PROJECT_DIR|g" \
    -e "s|__USER__|$CURRENT_USER|g" \
    systemd/geth-demo.service \
    | sudo tee /etc/systemd/system/geth-demo.service > /dev/null

sudo sed \
    -e "s|__PROJECT_DIR__|$PROJECT_DIR|g" \
    -e "s|__USER__|$CURRENT_USER|g" \
    systemd/geth-alert@.service \
    | sudo tee /etc/systemd/system/geth-alert@.service > /dev/null

sudo systemctl daemon-reload

echo
echo "Installation completed successfully."
echo
echo "Next steps:"
echo "sudo systemctl enable geth-demo.service"
echo "sudo systemctl restart geth-demo.service"
echo "sudo systemctl status geth-demo.service"
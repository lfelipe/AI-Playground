#!/bin/bash
# Helper script to interact with Signal channel in the container
DATA_DIR="$HOME/.config/AI-Playground/signal-cli-data"
LINK_URI_FILE="$DATA_DIR/latest_link_uri.txt"

case "$1" in
    qr)
        if [ -f "$LINK_URI_FILE" ]; then
            URI=$(cat "$LINK_URI_FILE")
            echo "Device Link URI: $URI"
            echo ""
            qrencode -t UTF8 "$URI"
        else
            echo "No active linking URI found yet. Start linking in WebUI or run: $0 start-link"
        fi
        ;;
    status)
        ACCOUNT_FILE="/app/home-agent/.signal_account"
        PEER_FILE="/app/home-agent/.signal_peer"
        echo "=== Signal Channel Status ==="
        if [ -f "$ACCOUNT_FILE" ]; then
            echo "Linked Account: $(cat "$ACCOUNT_FILE")"
        else
            echo "Linked Account: Not linked yet"
        fi
        if [ -f "$PEER_FILE" ]; then
            echo "Authorized Peer: $(cat "$PEER_FILE")"
        else
            echo "Authorized Peer: Not detected yet"
        fi
        ;;
    *)
        echo "Usage: $0 {qr|status}"
        ;;
esac

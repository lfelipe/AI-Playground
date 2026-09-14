#!/bin/bash
# Helper script to interact with Signal channel in the container
DATA_DIR="${AIPG_SIGNAL_CLI_HOME:-$HOME/.config/ai-playground/signal-cli-data}"
if [ ! -d "$DATA_DIR" ]; then
    DATA_DIR="$HOME/.config/AI-Playground/signal-cli-data"
fi
LINK_URI_FILE="$DATA_DIR/latest_link_uri.txt"

get_auth_token() {
    local pid=$(pgrep -f "web_api.py" | head -n1)
    if [ -n "$pid" ] && [ -r "/proc/$pid/environ" ]; then
        cat "/proc/$pid/environ" | tr '\0' '\n' | grep "^AIPG_LOOPBACK_TOKEN=" | cut -d= -f2
    fi
}

case "$1" in
    start-link)
        TOKEN=$(get_auth_token)
        if [ -z "$TOKEN" ]; then
            echo "Error: home-agent process not found or token unreadable"
            exit 1
        fi
        echo "Requesting startLink from Home Agent backend..."
        RES=$(curl -s -X POST -H "X-AIPG-Auth: $TOKEN" -H "Content-Type: application/json" http://127.0.0.1:58000/channel/signal/command/startLink)
        echo "$RES"
        if echo "$RES" | grep -q '"status":"ok"'; then
            echo ""
            "$0" qr
        fi
        ;;
    qr)
        if [ -f "$LINK_URI_FILE" ]; then
            URI=$(cat "$LINK_URI_FILE")
            echo "Device Link URI: $URI"
            echo ""
            echo "Scan this QR code in Signal (Settings -> Linked Devices -> +):"
            echo ""
            qrencode -t UTF8 "$URI"
        else
            echo "No active linking URI found yet. Run: $0 start-link"
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
        TOKEN=$(get_auth_token)
        if [ -n "$TOKEN" ]; then
            echo -n "Backend linkStatus: "
            curl -s -X POST -H "X-AIPG-Auth: $TOKEN" -H "Content-Type: application/json" http://127.0.0.1:58000/channel/signal/command/linkStatus
            echo ""
        fi
        ;;
    detect)
        TOKEN=$(get_auth_token)
        if [ -z "$TOKEN" ]; then
            echo "Error: home-agent process not found"
            exit 1
        fi
        echo "Detecting incoming Signal peer..."
        curl -s -H "X-AIPG-Auth: $TOKEN" http://127.0.0.1:58000/channel/signal/identity
        echo ""
        ;;
    *)
        echo "Usage: $0 {start-link|qr|status|detect}"
        ;;
esac

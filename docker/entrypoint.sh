#!/bin/bash
set -e

# If running as root, fix volume permissions and drop to lstrano
if [ "$(id -u)" = "0" ]; then
    rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true
    chown -R lstrano:lstrano /home/lstrano 2>/dev/null || true
    if [ -d "/app/WebUI/node_modules" ]; then
        chown -R lstrano:lstrano /app/WebUI/node_modules 2>/dev/null || true
    fi
    exec gosu lstrano "$0" "$@"
fi

# Clean up any stale X locks
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true

# Setup dbus session daemon if not running
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

echo "Starting Xvfb on display :99..."
Xvfb :99 -screen 0 1600x1000x24 -ac +extension GLX +render -noreset &
sleep 1

echo "Starting fluxbox window manager..."
fluxbox &
sleep 1

echo "Starting x11vnc..."
x11vnc -display :99 -forever -nopw -shared -rfbport 5900 -bg &
sleep 1

echo "Starting websockify/noVNC on port 6080..."
NOVNC_DIR="/usr/share/novnc"
if [ ! -d "$NOVNC_DIR" ]; then
    NOVNC_DIR="/usr/share/novnc-core"
fi
websockify --web="$NOVNC_DIR" 6080 localhost:5900 &
sleep 1

if [ "$#" -gt 0 ]; then
    exec "$@"
fi

if [ -d "/app/WebUI" ]; then
    cd /app/WebUI

    # Ensure node_modules and resources exist
    if [ ! -d "node_modules" ] || [ ! -f "node_modules/electron/path.txt" ]; then
        echo "Installing WebUI dependencies and resources..."
        npm install
        npm run fetch-external-resources
        npm run ensure-electron
        npm run ensure-native-modules || true
    fi

    # Pre-cache signal-cli in user's app data as well
    mkdir -p "$HOME/.config/AI-Playground/signal-cli/0.14.8"
    ln -sf /usr/local/bin/signal-cli "$HOME/.config/AI-Playground/signal-cli/0.14.8/signal-cli"

    echo "Launching AI Playground..."
    exec npm run dev
fi

exec sleep infinity

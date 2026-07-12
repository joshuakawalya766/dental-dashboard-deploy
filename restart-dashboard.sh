#!/bin/bash
# RESTART (offline) — e.g. after a power cut. Uses the local copy; no internet needed.

# If double-clicked from a file manager (no terminal), reopen in one so messages show.
if [ ! -t 1 ] && [ -z "$DASH_TERM" ]; then
  export DASH_TERM=1
  self="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  for t in x-terminal-emulator gnome-terminal konsole xfce4-terminal mate-terminal xterm; do
    command -v "$t" >/dev/null 2>&1 || continue
    case "$t" in
      gnome-terminal|mate-terminal) exec "$t" -- bash "$self" ;;
      xfce4-terminal)               exec "$t" -x bash "$self" ;;
      *)                            exec "$t" -e bash "$self" ;;
    esac
  done
fi

cd "$(dirname "$0")" || exit 1
C="docker compose -f docker-compose.yml -f docker-compose.linux.yml"
$C down; $C up -d || { echo "Could not start — is Docker running?  (sudo systemctl start docker)"; read -r -p "Press Enter…"; exit 1; }

# Open the browser as soon as the dashboard answers (up to ~30s), not a fixed wait.
( for _ in $(seq 1 60); do
    if command -v curl >/dev/null 2>&1; then curl -sf -o /dev/null http://localhost:4500 && break
    elif command -v wget >/dev/null 2>&1; then wget -q -O /dev/null http://localhost:4500 && break
    else sleep 4; break; fi
    sleep 0.5
  done
  command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:4500 >/dev/null 2>&1 ) &

echo "Restarted at http://localhost:4500 (offline)."
[ -n "$DASH_TERM" ] && read -r -p "Press Enter to close this window…"

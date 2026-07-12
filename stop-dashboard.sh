#!/bin/bash
# STOP the dashboard (your clinic data + photos are kept).

# If double-clicked from a file manager (no terminal), reopen in one so the result shows.
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
docker compose -f docker-compose.yml -f docker-compose.linux.yml down
echo "Stopped. (Your clinic data + photos are kept.)"
[ -n "$DASH_TERM" ] && read -r -p "Press Enter to close this window…"

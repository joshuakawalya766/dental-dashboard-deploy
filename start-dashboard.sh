#!/bin/bash
# START (offline-first). Only the FIRST run needs internet (to download the app);
# every start after that boots from the local copy with no internet.

# If double-clicked from a file manager (no terminal attached), reopen inside a terminal
# window so the messages/prompts below are visible. (macOS .command and Windows .bat do
# this on their own — this is only for Linux file managers.)
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
  # No terminal emulator found — carry on headless (still works, just silently).
fi

cd "$(dirname "$0")" || exit 1
C="docker compose -f docker-compose.yml -f docker-compose.linux.yml"
IMG="ghcr.io/joshuakawalya766/dental-dashboard:latest"
# Pass the read-only token to the app (for the opportunistic "update available" check).
[ -f ghcr-token.txt ] && printf 'GHCR_TOKEN=%s\n' "$(tr -d '\r\n' < ghcr-token.txt)" > .env
if ! docker image inspect "$IMG" >/dev/null 2>&1; then
  echo "First-time setup: downloading the dashboard (needs internet this once)…"
  [ -f ghcr-token.txt ] && docker login ghcr.io -u joshuakawalya766 --password-stdin < ghcr-token.txt >/dev/null 2>&1
  $C pull || { echo "Download failed — check the internet and ghcr-token.txt."; read -r -p "Press Enter…"; exit 1; }
fi
echo "Starting (runs offline)…"
$C up -d || { echo "Could not start — is Docker running?  (sudo systemctl start docker)"; read -r -p "Press Enter…"; exit 1; }

# Open the browser as soon as the dashboard actually answers (up to ~30s), instead of a
# fixed guess — so the tab opens promptly whether run in a terminal or by double-click.
( for _ in $(seq 1 60); do
    if command -v curl >/dev/null 2>&1; then curl -sf -o /dev/null http://localhost:4500 && break
    elif command -v wget >/dev/null 2>&1; then wget -q -O /dev/null http://localhost:4500 && break
    else sleep 4; break; fi
    sleep 0.5
  done
  command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:4500 >/dev/null 2>&1 ) &

echo "Running at http://localhost:4500 — no internet needed from here on."
echo "Phone can't connect and a firewall is on?  sudo ufw allow 4500/tcp && sudo ufw allow 4543/tcp"
[ -n "$DASH_TERM" ] && read -r -p "Press Enter to close this window…"

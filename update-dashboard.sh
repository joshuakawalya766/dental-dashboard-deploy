#!/bin/bash
# UPDATE (needs internet) — download the latest version, then you can go offline again.

# If double-clicked from a file manager (no terminal attached), reopen inside a terminal —
# otherwise the "Press Enter to update" prompt below is invisible and it looks like nothing
# happens. (macOS .command and Windows .bat open a window on their own.)
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
echo "————————————————————————————————————————————————————————"
echo "  Update the Dental Dashboard"
echo "  • Please finish and SAVE any open work first (receipts, posts)."
echo "  • The dashboard briefly stops and restarts — your data is safe"
echo "    (it lives in ./data and ./images and survives updates)."
echo "————————————————————————————————————————————————————————"
read -r -p "Press Enter to update now, or close this window to cancel… "
[ -f ghcr-token.txt ] && printf 'GHCR_TOKEN=%s\n' "$(tr -d '\r\n' < ghcr-token.txt)" > .env
echo "Downloading the latest version (needs internet)…"
[ -f ghcr-token.txt ] && docker login ghcr.io -u joshuakawalya766 --password-stdin < ghcr-token.txt >/dev/null 2>&1
if $C pull && $C up -d; then
  docker image prune -f >/dev/null 2>&1   # delete the previous version's now-orphaned layers so updates don't pile up on disk
  echo "Updated ✔  You can disconnect from the internet again."
else
  echo "Update failed — check the internet and ghcr-token.txt."
fi
read -r -p "Press Enter to close this window… "

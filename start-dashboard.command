#!/bin/bash
# START (offline-first, macOS). First run needs internet; after that it boots offline.
cd "$(dirname "$0")" || exit 1
export HOST_LAN_IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)"
IMG="ghcr.io/joshuakawalya766/dental-dashboard:latest"
[ -f ghcr-token.txt ] && printf 'GHCR_TOKEN=%s\n' "$(tr -d '\r\n' < ghcr-token.txt)" > .env
if ! docker image inspect "$IMG" >/dev/null 2>&1; then
  echo "First-time setup: downloading the dashboard (needs internet this once)…"
  [ -f ghcr-token.txt ] && docker login ghcr.io -u joshuakawalya766 --password-stdin < ghcr-token.txt >/dev/null 2>&1
  docker compose pull || { echo "Download failed — check internet + ghcr-token.txt."; read -r -p "Enter…"; exit 1; }
fi
echo "Starting (runs offline)…"
docker compose up -d || { echo "Is Docker Desktop running?"; read -r -p "Enter…"; exit 1; }
# Open the browser as soon as the dashboard answers (up to ~30s), not a fixed wait.
( for _ in $(seq 1 60); do curl -sf -o /dev/null http://localhost:4500 && break; sleep 0.5; done
  command -v open >/dev/null 2>&1 && open http://localhost:4500 ) &
echo "Running at http://localhost:4500 — no internet needed from here on."; read -r -p "Press Enter to close…"

#!/bin/bash
# START (offline-first). Only the FIRST run needs internet (to download the app);
# every start after that boots from the local copy with no internet.
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
sleep 4; command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:4500 >/dev/null 2>&1
echo "Running at http://localhost:4500 — no internet needed from here on."
echo "Phone can't connect and a firewall is on?  sudo ufw allow 4500/tcp && sudo ufw allow 4543/tcp"

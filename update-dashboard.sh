#!/bin/bash
# UPDATE (needs internet) — download the latest version, then you can go offline again.
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
if $C pull && $C up -d; then echo "Updated ✔  You can disconnect from the internet again."; else echo "Update failed — check the internet and ghcr-token.txt."; read -r -p "Press Enter…"; fi

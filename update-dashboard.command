#!/bin/bash
# UPDATE (needs internet, macOS).
cd "$(dirname "$0")" || exit 1
[ -f ghcr-token.txt ] && printf 'GHCR_TOKEN=%s\n' "$(tr -d '\r\n' < ghcr-token.txt)" > .env
echo "Downloading the latest version (needs internet)…"
[ -f ghcr-token.txt ] && docker login ghcr.io -u joshuakawalya766 --password-stdin < ghcr-token.txt >/dev/null 2>&1
if docker compose pull && docker compose up -d; then echo "Updated. You can go offline again."; else echo "Update failed — check internet + token."; fi
read -r -p "Press Enter to close…"

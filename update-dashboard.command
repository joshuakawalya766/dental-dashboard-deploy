#!/bin/bash
# UPDATE (needs internet, macOS).
cd "$(dirname "$0")" || exit 1
echo "————————————————————————————————————————————————————————"
echo "  Update the Dental Dashboard"
echo "  • Please finish and SAVE any open work first (receipts, posts)."
echo "  • The dashboard briefly stops and restarts — your data is safe."
echo "————————————————————————————————————————————————————————"
read -r -p "Press Enter to update now, or close this window to cancel… "
[ -f ghcr-token.txt ] && printf 'GHCR_TOKEN=%s\n' "$(tr -d '\r\n' < ghcr-token.txt)" > .env
echo "Downloading the latest version (needs internet)…"
[ -f ghcr-token.txt ] && docker login ghcr.io -u joshuakawalya766 --password-stdin < ghcr-token.txt >/dev/null 2>&1
if docker compose pull && docker compose up -d; then
  docker image prune -f >/dev/null 2>&1   # remove the old version's orphaned layers so disk use doesn't grow each update
  echo "Updated. You can go offline again."
else
  echo "Update failed — check internet + token."
fi
read -r -p "Press Enter to close…"

#!/bin/bash
# RESTART (offline) — e.g. after a power cut. Uses the local copy; no internet needed.
cd "$(dirname "$0")" || exit 1
C="docker compose -f docker-compose.yml -f docker-compose.linux.yml"
$C down; $C up -d
sleep 4; command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:4500 >/dev/null 2>&1
echo "Restarted at http://localhost:4500 (offline)."

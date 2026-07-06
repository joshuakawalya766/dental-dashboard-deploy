#!/bin/bash
cd "$(dirname "$0")" || exit 1
export HOST_LAN_IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)"
docker compose down; docker compose up -d
sleep 5; command -v open >/dev/null 2>&1 && open http://localhost:4500
echo "Restarted at http://localhost:4500 (offline)."; read -r -p "Press Enter to close…"

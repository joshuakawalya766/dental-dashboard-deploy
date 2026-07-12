#!/bin/bash
cd "$(dirname "$0")" || exit 1
export HOST_LAN_IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)"
docker compose down; docker compose up -d
# Open the browser as soon as the dashboard answers (up to ~30s), not a fixed wait.
( for _ in $(seq 1 60); do curl -sf -o /dev/null http://localhost:4500 && break; sleep 0.5; done
  command -v open >/dev/null 2>&1 && open http://localhost:4500 ) &
echo "Restarted at http://localhost:4500 (offline)."; read -r -p "Press Enter to close…"

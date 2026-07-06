#!/bin/bash
cd "$(dirname "$0")" || exit 1
docker compose down
echo "Stopped. (Your clinic data + photos are kept.)"; read -r -p "Press Enter to close…"

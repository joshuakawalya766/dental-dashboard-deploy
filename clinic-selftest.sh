#!/bin/bash
# From-scratch clinic install simulation. Proves a machine with ONLY the image + a
# compose file (no source, no generator, no dev docs) boots to a working, unlicensed,
# clinic-clean dashboard — with the built-in tips seeded and NO secrets baked.
#
# Runs on a throwaway port (4700) in a temp folder, so it won't touch your real
# dashboard. On a real clinic the image is PULLED from GHCR; here it uses the local
# image if you've built one.
set -euo pipefail
IMG="ghcr.io/joshuakawalya766/dental-dashboard:latest"
PORT=4700
NAME="clinic-selftest"
TMP="$(mktemp -d /tmp/clinic-test-XXXXXX)"
cleanup() { docker compose -f "$TMP/docker-compose.yml" down >/dev/null 2>&1 || true; rm -rf "$TMP"; }
trap cleanup EXIT

echo "▶ Fresh 'clinic machine' folder: $TMP (only a compose file + empty data/images)"
mkdir -p "$TMP/data" "$TMP/images"
cat > "$TMP/docker-compose.yml" <<YAML
services:
  dashboard:
    image: $IMG
    container_name: $NAME
    ports: [ "$PORT:4500" ]
    volumes: [ "./data:/app/data", "./images:/app/images" ]
    environment: [ "PORT=4500" ]
YAML

if ! docker image inspect "$IMG" >/dev/null 2>&1; then
  echo "▶ Image not local — logging in + pulling from GHCR (what a real clinic does)…"
  D="$(cd "$(dirname "$0")" && pwd)"
  [ -f "$D/ghcr-token.txt" ] && mv -f "$D/ghcr-token.txt" "$D/.ghcr-token"   # a pasted replacement key always wins
  [ -f "$D/.ghcr-token" ] && docker login ghcr.io -u joshuakawalya766 --password-stdin < "$D/.ghcr-token" >/dev/null 2>&1
  docker compose -f "$TMP/docker-compose.yml" pull
fi
echo "▶ Starting…"
docker compose -f "$TMP/docker-compose.yml" up -d >/dev/null

echo "▶ Waiting for boot…"
for i in $(seq 1 25); do curl -sf "http://localhost:$PORT/api/config" >/dev/null 2>&1 && break; sleep 1; done

echo "▶ Clinic-clean checks:"
curl -s "http://localhost:$PORT/api/config" | node -e '
let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const j=JSON.parse(s);
const ok=(c,m)=>console.log((c?"  ✅":"  ❌")+" "+m);
ok(j.locked===true, "starts LOCKED (no license baked in)");
ok(j.license && j.license.valid===false, "no valid license present");
ok(j.entitlements && !j.entitlements.report && !j.entitlements.records, "Report/Records locked until a Pro key");
ok(Array.isArray(j.captions) && j.captions.length>0, "built-in tips seeded ("+((j.captions||[]).length)+")");
ok(!j.brand || !j.brand.name, "no clinic brand baked (blank slate)");
});'

echo "▶ Image is clean (no secrets/records outside the runtime data volume):"
if docker exec "$NAME" sh -c "find /app -not -path '*/data/*' -not -path '*/node_modules/*' \( -name '*.pem' -o -name 'reports.json' -o -name 'settings.json' -o -name 'license.json' \) 2>/dev/null" | grep -q .; then
  echo "  ❌ LEAK found in image"
else
  echo "  ✅ none"
fi

echo "✔ Self-test complete — tearing down."

# Dental Dashboard — deployment kit

Everything a clinic computer needs to run the **Dental Dashboard** — an offline-first
dashboard for dental clinics (branded social posts, receipts, searchable records). It
pulls a prebuilt app image from a registry; **no source code, no build tools.**

> This repo is just the **deployment scripts** — it contains no secrets. The app image
> itself is **private**; pulling it needs a read-only token your provider gives you
> (see [For the provider](#for-the-provider)).

## One-time setup
1. Install **Docker** — Docker Desktop on Windows/Mac (<https://www.docker.com/products/docker-desktop>),
   or Docker Engine on Linux (`sudo apt install docker.io docker-compose-v2`).
2. Put this folder on the computer (`git clone` it, or copy it).
3. Make sure your **update key** is in this folder — **`.ghcr-token`** (hidden; your provider
   supplies it). An older visible `ghcr-token.txt` still works and is hidden automatically on
   first start. The Start
   launcher uses it to sign in and download the app automatically — nothing to type.

## Every day (double-click)
| | Windows | macOS | Linux | Internet? |
|---|---|---|---|---|
| **Start** | `Start-Dashboard.bat` | `start-dashboard.command` | `start-dashboard.sh` | only the **very first** time |
| **Stop** | `Stop-Dashboard.bat` | `stop-dashboard.command` | `stop-dashboard.sh` | no |
| **Restart** | `Restart-Dashboard.bat` | `restart-dashboard.command` | `restart-dashboard.sh` | no |
| **Update** | `Update-Dashboard.bat` | `update-dashboard.command` | `update-dashboard.sh` | **yes** (a couple of minutes) |

It opens at **<http://localhost:4500>**. First run is **locked** — paste the license key
from your provider in **Settings → License → Activate**. Built-in dental tips are already
there; set the clinic name/logo/prices in **Settings**.

> **Offline-first:** internet is needed **only** for the first install and when you run
> **Update**. After that it runs 100% offline — add patients, print receipts, and connect
> phones over the clinic Wi-Fi even with the router unplugged.

> **When to use Stop:** almost never. It runs as a background service and returns after a
> power cut on its own. You don't need Stop to update (the **Update** launcher handles it)
> or when the Wi-Fi changes (tap 📱 → **🔄 Refresh** on the QR screen). Use **Stop** only to
> deliberately keep it off, or to free the computer's memory for a while.

## Or by command
```bash
docker compose up -d                        # start   (Linux host mode: add -f docker-compose.yml -f docker-compose.linux.yml)
docker compose pull && docker compose up -d # update to the latest version
docker compose down                         # stop
```

## Notes
- **Linux** uses **host networking** (via the launchers) so the phone-QR auto-detects the
  current Wi-Fi address. If a firewall is on: `sudo ufw allow 4500/tcp && sudo ufw allow 4543/tcp`.
- **Windows/Mac**: if the phone can't connect, open the 📱 QR screen and type this
  computer's Wi-Fi address once (it's remembered).
- Your clinic data + photos live in **`./data`** and **`./images`** (created on first run)
  and survive updates. Back them up occasionally.
- `clinic-selftest.sh` boots a throwaway copy on port 4700 to verify a clean install.

## For the provider
The app image is **private** on GitHub Container Registry. Clinics pull it with a
**read-only token** — always read-only, always with an **expiry** (a **1-year** expiry is a
good balance: it rarely breaks mid-visit, and a leaked token dies on its own). Rotate it
when it expires (existing installs keep running offline regardless — a token is only needed
for a fresh install or an update).

1. Create the token (either works):
   - **Recommended (least privilege):** GitHub → Settings → Developer settings →
     **Fine-grained tokens** → Repository access **None** → Permissions → **Packages: Read-only**
     → **1-year expiry**. Test it: `echo TOKEN | docker login ghcr.io -u <user> --password-stdin`
     then `docker pull ghcr.io/<user>/dental-dashboard:latest`.
   - **Reliable fallback:** **Tokens (classic)** → scope **`read:packages`** only.
2. Copy `ghcr-token.txt.example` → **`.ghcr-token`** (leading dot = hidden) and paste the token (this file is
   git-ignored — never commit it). Ship it inside the clinic's copy of this folder.
3. Keep the image **package Private**. The token is read-only and revocable.

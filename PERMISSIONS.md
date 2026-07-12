# Permissions & first-run prompts

The dashboard runs inside **Docker**, so day-to-day it writes its files (patient records,
images, config) with **no permission prompts at all** — the OS sees one authorised program
(Docker), and the app only ever writes inside its own mounted folders (`./data`, `./images`,
`./exports`, created automatically on first run). A clinic just double-clicks **Start** and
uses it; no UAC popups, no macOS access flags per save.

Permissions only appear **once, at initial setup**:

| Step | Windows | macOS | Linux |
| --- | --- | --- | --- |
| **Install Docker** | Admin/UAC prompt during Docker Desktop install | Admin password during Docker Desktop install | Install via package manager; add your user to the `docker` group (or use `sudo`) |
| **File sharing** | Docker may ask to **share the `C:` drive** — Allow once | If the kit is in **Documents/Desktop/Downloads**, macOS asks *"Allow Docker to access files in this folder?"* — Allow once (a neutral path like `/Users/Shared/` avoids it) | None — the container's entrypoint aligns file ownership (`chown`) automatically |
| **Firewall (phone access)** | First LAN/phone connection may prompt *"Allow on private networks?"* — Allow | Same prompt on first phone connection — Allow | `sudo ufw allow 4500/tcp && sudo ufw allow 4543/tcp` if a firewall is on |

After that first run, it's silent. This is actually **fewer** prompts than a normal native
`.exe`/`.app`, which would hit OS privacy/UAC dialogs on folder creation and file writes —
Docker's sandbox absorbs all of that.

## Note on data folders
`./data`, `./images` and `./exports` hold the clinic's real data and are created next to the
launcher scripts. **Don't delete them** — updates (`pull` + `up`) never touch them, so they
survive across versions. The app also mirrors its machine **Install ID** into `./images` and
`./exports`, so a stray reset of `./data` alone won't re-key the machine and break the license.

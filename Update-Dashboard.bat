@echo off
REM UPDATE (needs internet).
cd /d "%~dp0"
echo ============================================================
echo   Update the Dental Dashboard
echo   * Please finish and SAVE any open work first (receipts, posts).
echo   * The dashboard briefly stops and restarts - your data is safe
echo     (it lives in .\data and .\images and survives updates).
echo ============================================================
echo Press any key to update now, or close this window to cancel...
pause >nul
REM The update key: ONE canonical name on every platform — .ghcr-token.
REM Explorer won't let a user CREATE a dot-file, so a plain ghcr-token.txt is renamed once.
REM A pasted ghcr-token.txt ALWAYS wins — it is the only way a Windows clinic can deliver a
REM REPLACEMENT key (Explorer can't create dot-files). Ignoring it silently breaks rotation.
if exist ghcr-token.txt move /Y ghcr-token.txt .ghcr-token >nul
if exist .ghcr-token attrib +h .ghcr-token
if exist .ghcr-token powershell -NoProfile -Command "Set-Content .env ('GHCR_TOKEN=' + (Get-Content '.ghcr-token' -Raw).Trim())"
if exist .env attrib +h .env
echo Downloading the latest version (needs internet)...
if exist .ghcr-token (type .ghcr-token | docker login ghcr.io -u joshuakawalya766 --password-stdin >nul 2>&1)
docker compose pull
docker compose up -d
docker image prune -f >nul 2>&1
echo Updated. You can go offline again.
pause

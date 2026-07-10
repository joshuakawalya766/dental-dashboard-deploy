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
if exist ghcr-token.txt powershell -NoProfile -Command "Set-Content .env ('GHCR_TOKEN=' + (Get-Content ghcr-token.txt -Raw).Trim())"
echo Downloading the latest version (needs internet)...
if exist ghcr-token.txt (type ghcr-token.txt | docker login ghcr.io -u joshuakawalya766 --password-stdin >nul 2>&1)
docker compose pull
docker compose up -d
docker image prune -f >nul 2>&1
echo Updated. You can go offline again.
pause

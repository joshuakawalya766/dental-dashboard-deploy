@echo off
REM UPDATE (needs internet).
cd /d "%~dp0"
if exist ghcr-token.txt powershell -NoProfile -Command "Set-Content .env ('GHCR_TOKEN=' + (Get-Content ghcr-token.txt -Raw).Trim())"
echo Downloading the latest version (needs internet)...
if exist ghcr-token.txt (type ghcr-token.txt | docker login ghcr.io -u joshuakawalya766 --password-stdin >nul 2>&1)
docker compose pull
docker compose up -d
echo Updated. You can go offline again.
pause

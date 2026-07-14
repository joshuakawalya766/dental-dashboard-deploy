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
REM The update key. Marked HIDDEN so it can't be deleted or copied by accident while
REM browsing the folder. (Windows keeps the .txt name; attrib +h hides it in Explorer.)
if exist ghcr-token.txt attrib +h ghcr-token.txt
set "TOKENFILE="
if exist ghcr-token.txt set "TOKENFILE=ghcr-token.txt"
if exist .ghcr-token set "TOKENFILE=.ghcr-token"
if defined TOKENFILE powershell -NoProfile -Command "Set-Content .env ('GHCR_TOKEN=' + (Get-Content '%TOKENFILE%' -Raw).Trim())"
if exist .env attrib +h .env
echo Downloading the latest version (needs internet)...
if defined TOKENFILE (type "%TOKENFILE%" | docker login ghcr.io -u joshuakawalya766 --password-stdin >nul 2>&1)
docker compose pull
docker compose up -d
docker image prune -f >nul 2>&1
echo Updated. You can go offline again.
pause

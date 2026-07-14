@echo off
REM START (offline-first). First run downloads the app; later starts are offline.
cd /d "%~dp0"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 ^| Where-Object {($_.IPAddress -like '192.168.*') -or ($_.IPAddress -like '10.*')} ^| Select-Object -First 1 -ExpandProperty IPAddress)" 2^>nul') do set HOST_LAN_IP=%%i
REM The update key. Marked HIDDEN so it can't be deleted or copied by accident while
REM browsing the folder. (Windows keeps the .txt name; attrib +h hides it in Explorer.)
if exist ghcr-token.txt attrib +h ghcr-token.txt
set "TOKENFILE="
if exist ghcr-token.txt set "TOKENFILE=ghcr-token.txt"
if exist .ghcr-token set "TOKENFILE=.ghcr-token"
if defined TOKENFILE powershell -NoProfile -Command "Set-Content .env ('GHCR_TOKEN=' + (Get-Content '%TOKENFILE%' -Raw).Trim())"
if exist .env attrib +h .env
docker image inspect ghcr.io/joshuakawalya766/dental-dashboard:latest >nul 2>&1
if errorlevel 1 (
  echo First-time setup: downloading the dashboard ^(needs internet this once^)...
  if defined TOKENFILE (type "%TOKENFILE%" | docker login ghcr.io -u joshuakawalya766 --password-stdin >nul 2>&1)
  docker compose pull || (echo Download failed - check internet and your update key. & pause & exit /b 1)
)
echo Starting (runs offline)...
docker compose up -d || (echo Is Docker Desktop running? & pause & exit /b 1)
timeout /t 5 /nobreak >nul & start "" http://localhost:4500
echo Running at http://localhost:4500 - no internet needed from here on.
pause

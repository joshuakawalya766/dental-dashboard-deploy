@echo off
REM START (offline-first). First run downloads the app; later starts are offline.
cd /d "%~dp0"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 ^| Where-Object {($_.IPAddress -like '192.168.*') -or ($_.IPAddress -like '10.*')} ^| Select-Object -First 1 -ExpandProperty IPAddress)" 2^>nul') do set HOST_LAN_IP=%%i
REM The update key: ONE canonical name on every platform — .ghcr-token.
REM Explorer won't let a user CREATE a dot-file, so a plain ghcr-token.txt is renamed once.
REM A pasted ghcr-token.txt ALWAYS wins — it is the only way a Windows clinic can deliver a
REM REPLACEMENT key (Explorer can't create dot-files). Ignoring it silently breaks rotation.
if exist ghcr-token.txt move /Y ghcr-token.txt .ghcr-token >nul
if exist .ghcr-token attrib +h .ghcr-token
if exist .ghcr-token powershell -NoProfile -Command "Set-Content .env ('GHCR_TOKEN=' + (Get-Content '.ghcr-token' -Raw).Trim())"
if exist .env attrib +h .env
docker image inspect ghcr.io/joshuakawalya766/dental-dashboard:latest >nul 2>&1
if errorlevel 1 (
  echo First-time setup: downloading the dashboard ^(needs internet this once^)...
  if exist .ghcr-token (type .ghcr-token | docker login ghcr.io -u joshuakawalya766 --password-stdin >nul 2>&1)
  docker compose pull || (echo Download failed - check internet and your update key. & pause & exit /b 1)
)
echo Starting (runs offline)...
docker compose up -d || (echo Is Docker Desktop running? & pause & exit /b 1)
timeout /t 5 /nobreak >nul & start "" http://localhost:4500
echo Running at http://localhost:4500 - no internet needed from here on.
pause

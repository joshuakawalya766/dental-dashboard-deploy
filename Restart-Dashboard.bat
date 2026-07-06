@echo off
cd /d "%~dp0"
docker compose down
docker compose up -d
timeout /t 4 /nobreak >nul & start "" http://localhost:4500
echo Restarted (offline). You can close this window.
pause

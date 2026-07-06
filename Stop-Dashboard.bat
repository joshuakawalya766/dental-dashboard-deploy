@echo off
cd /d "%~dp0"
docker compose down
echo Stopped. You can close this window.
pause

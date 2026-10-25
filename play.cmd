@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

rem If the local agent is already running, just open the game.
curl.exe -s -o NUL --max-time 2 "http://127.0.0.1:8000/api/health"
if not errorlevel 1 (
  start "" "http://127.0.0.1:8000/"
  exit /b 0
)

rem Otherwise launch the full local stack (FastAPI + static build).
call "%~dp0start.cmd"

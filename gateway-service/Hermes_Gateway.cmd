@echo off
rem Hermes Agent Gateway - Messaging Platform Integration
cd /d "%~dp0.."
set "HERMES_HOME=%~dp0.."
set "PYTHONIOENCODING=utf-8"
set "HERMES_GATEWAY_DETACHED=1"
set "HERMES_EXE=%~dp0..\hermes-agent\venv\Scripts\hermes.exe"
if not exist "%HERMES_EXE%" set "HERMES_EXE=%~dp0..\bin\hermes.exe"
"%HERMES_EXE%" gateway run
exit /b 0
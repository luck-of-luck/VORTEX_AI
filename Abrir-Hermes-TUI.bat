@echo off
setlocal
title Hermes - TUI
cd /d "%~dp0hermes-agent"
set "HERMES_HOME=%~dp0"
echo Iniciando Hermes TUI...
echo.
set "HERMES_EXE=%~dp0hermes-agent\venv\Scripts\hermes.exe"
if not exist "%HERMES_EXE%" set "HERMES_EXE=%~dp0bin\hermes.exe"
if not exist "%HERMES_EXE%" (
  echo [ERRO] hermes.exe nao encontrado. Rode setup.ps1 antes.
  pause
  exit /b 1
)
"%HERMES_EXE%" --tui
pause
@echo off
setlocal
title Hermes - TUI - VORTEX_AI
cd /d "%~dp0hermes-agent"
set "HERMES_HOME=%~dp0"
echo ==========================================
echo  Hermes TUI - VORTEX_AI
echo  HERMES_HOME: %HERMES_HOME%
echo ==========================================
echo.
set "HERMES_EXE=%~dp0hermes-agent\venv\Scripts\hermes.exe"
if not exist "%HERMES_EXE%" set "HERMES_EXE=%~dp0bin\hermes.exe"
if not exist "%HERMES_EXE%" (
  echo [ERRO] hermes.exe nao encontrado.
  echo Rode antes: duplo-clique em setup.bat
  echo Ou: powershell -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
  pause
  exit /b 1
)
if not exist "%~dp0.env" (
  echo [AVISO] .env nao encontrado. Rode setup.bat primeiro.
  echo.
)
echo Iniciando Hermes TUI...
"%HERMES_EXE%" --tui
pause
@echo off
setlocal
title Hermes CLI
cd /d "%~dp0hermes-agent"
set "HERMES_HOME=%~dp0"
echo ==========================================
echo  Hermes CLI
echo  HERMES_HOME: %HERMES_HOME%
echo  Pasta: %CD%
echo ==========================================
echo.
set "HERMES_EXE=%~dp0hermes-agent\venv\Scripts\hermes.exe"
if not exist "%HERMES_EXE%" set "HERMES_EXE=%~dp0bin\hermes.exe"
if not exist "%HERMES_EXE%" (
  echo [ERRO] hermes.exe nao encontrado.
  echo Rode antes:  powershell -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
  pause
  exit /b 1
)
"%HERMES_EXE%" %*
echo.
echo Hermes saiu com codigo %errorlevel%
pause
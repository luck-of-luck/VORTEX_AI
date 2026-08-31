@echo off
setlocal
title Hermes CLI - VORTEX_AI
cd /d "%~dp0hermes-agent"
set "HERMES_HOME=%~dp0"
echo ==========================================
echo  Hermes CLI - VORTEX_AI
echo  HERMES_HOME: %HERMES_HOME%
echo  Pasta: %CD%
echo ==========================================
echo.
set "HERMES_EXE=%~dp0hermes-agent\venv\Scripts\hermes.exe"
if not exist "%HERMES_EXE%" set "HERMES_EXE=%~dp0bin\hermes.exe"
if not exist "%HERMES_EXE%" (
  echo [ERRO] hermes.exe nao encontrado.
  echo.
  echo Voce precisa rodar o setup primeiro:
  echo   Duplo-clique em setup.bat  na raiz do projeto
  echo   Ou: powershell -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
  echo.
  pause
  exit /b 1
)
if not exist "%~dp0.env" (
  echo [AVISO] .env nao encontrado. O setup cria automaticamente.
  echo Rode setup.bat antes, ou copie .env.example para .env e preencha 1 chave.
  echo Continuando mesmo assim (fallback local pode funcionar)...
  echo.
)
"%HERMES_EXE%" %*
echo.
echo Hermes saiu com codigo %errorlevel%
pause
@echo off
setlocal
title OpenCode - Hermes - VORTEX_AI
cd /d "%~dp0"
echo ==========================================
echo  OpenCode - Hermes RAIZ - VORTEX_AI
echo  Pasta: %CD%
echo  Config: %CD%\opencode.jsonc
echo  MCP: hermes -^> bin\hermes.exe mcp serve
echo ==========================================
echo.
if not exist "%CD%\hermes-agent\venv\Scripts\hermes.exe" if not exist "%CD%\bin\hermes.exe" (
  echo [AVISO] hermes.exe nao encontrado. Rode setup.bat primeiro.
  echo.
)
where opencode >nul 2>nul
if %errorlevel% neq 0 (
  echo [ERRO] opencode nao encontrado no PATH.
  echo Instale via:  npm install -g opencode-ai
  echo Ou rode: setup.bat  (ele oferece instalar)
  echo Node.js: https://nodejs.org/
  pause
  exit /b 1
)
echo Iniciando OpenCode... (Ctrl+C cancela)
opencode %*
pause
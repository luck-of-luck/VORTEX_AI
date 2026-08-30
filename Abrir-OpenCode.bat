@echo off
setlocal
title OpenCode - Hermes
cd /d "%~dp0"
echo ==========================================
echo  OpenCode - Hermes RAIZ
echo  Pasta: %CD%
echo  Config: %CD%\opencode.jsonc
echo  MCP: hermes -^> bin\hermes.exe mcp serve
echo ==========================================
echo.
where opencode >nul 2>nul
if %errorlevel% neq 0 (
  echo [ERRO] opencode nao encontrado no PATH.
  echo Instale via:  npm install -g opencode-ai
  pause
  exit /b 1
)
echo Iniciando TUI... (Ctrl+C cancela)
opencode %*
pause
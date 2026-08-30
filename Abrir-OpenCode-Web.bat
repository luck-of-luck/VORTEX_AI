@echo off
setlocal
title OpenCode WEB - Hermes
cd /d "%~dp0"
echo Iniciando OpenCode WEB em %CD%
echo Isso abre o navegador em http://localhost:4096
where opencode >nul 2>nul
if %errorlevel% neq 0 (
  echo [ERRO] opencode nao encontrado. Instale: npm install -g opencode-ai
  pause
  exit /b 1
)
opencode web
pause
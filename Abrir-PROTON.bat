@echo off
setlocal
title PROTON - JARVIS - VORTEX_AI
cd /d "%~dp0"
echo ==========================================
echo  PROTON - JARVIS (VORTEX_AI)
echo  Interface RTX | Grafite metalico | Neon
echo  Pasta: %CD%
echo ==========================================
echo.
if not exist "proton\index.html" (
  echo [ERRO] proton\index.html nao encontrado.
  echo Rode setup.bat ou git pull.
  pause
  exit /b 1
)
echo Abrindo PROTON em seu navegador padrao...
echo  - Interface: proton\index.html
echo  - Hermes MCP: bin\hermes.exe mcp serve (opencode)
echo  - Dica: use Chrome/Edge para voz + RTX
echo.
start "" "%~dp0proton\index.html"
echo PROTON aberto. Se nao abriu, duplo-clique em proton\index.html
echo.
pause

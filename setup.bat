@echo off
setlocal EnableDelayedExpansion
title VORTEX_AI - Setup
cd /d "%~dp0"
echo.
echo  ==========================================================
echo   VORTEX_AI / Hermes Agent - Setup (Windows)
echo   Pasta: %CD%
echo  ==========================================================
echo.

REM -- Detecta PowerShell disponivel (prefere pwsh 7+, cai para powershell 5.1)
set "PS_EXE="
where pwsh >nul 2>nul
if %errorlevel% equ 0 (
    set "PS_EXE=pwsh"
) else (
    where powershell >nul 2>nul
    if %errorlevel% equ 0 (
        set "PS_EXE=powershell"
    ) else (
        REM fallback: tenta chamar diretamente (where pode falhar em alguns shells)
        pwsh -NoProfile -Command "exit 0" >nul 2>nul
        if %errorlevel% equ 0 (
            set "PS_EXE=pwsh"
        ) else (
            powershell -NoProfile -Command "exit 0" >nul 2>nul
            if %errorlevel% equ 0 set "PS_EXE=powershell"
        )
    )
)

if "%PS_EXE%"=="" (
    echo [ERRO] PowerShell nao encontrado no PATH.
    echo Instale PowerShell 5.1+ ou PowerShell 7: https://aka.ms/powershell
    echo.
    pause
    exit /b 1
)

echo [INFO] Usando: %PS_EXE%
echo [INFO] Executando setup.ps1 ...
echo.

REM -- Normaliza --verify para -VerifyOnly (usuario pode usar setup.bat --verify)
set "SETUP_ARGS=%*"
if not "%SETUP_ARGS%"=="" (
    set "SETUP_ARGS=!SETUP_ARGS:--verify=-VerifyOnly!"
    set "SETUP_ARGS=!SETUP_ARGS:--Verify=-VerifyOnly!"
    set "SETUP_ARGS=!SETUP_ARGS:verify=-VerifyOnly!"
)
REM -- Forward todos os argumentos para setup.ps1 (ex: setup.bat -Extras "messaging,mcp" -WithN8nMCP -VerifyOnly)
if defined SETUP_ARGS (
    "%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" !SETUP_ARGS!
) else (
    "%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
)

set "EXITCODE=%errorlevel%"
echo.
if %EXITCODE% neq 0 (
    echo  [ERRO] setup.ps1 falhou com codigo %EXITCODE%
    echo  Veja as mensagens acima. Tente:
    echo    - Rodar como Administrador se falhou ao instalar Python
    echo    - Instalar Python 3.11-3.13 manualmente: https://www.python.org/downloads/
    echo    - Depois rodar novamente: setup.bat
    echo.
    pause
    exit /b %EXITCODE%
)

echo  ==========================================================
echo   Setup concluido com sucesso!
echo  ==========================================================
echo.
echo  Proximos passos:
echo    1) Edite o arquivo .env e preencha pelo menos UMA chave:
echo       - CLINE_API_KEY  (recomendado, gratis/experimentacao: https://app.cline.bot)
echo       - OPENROUTER_API_KEY (gratis :free: https://openrouter.ai)
echo       - Ou use Ollama local 100%% gratis/offline (https://ollama.com)
echo.
echo    2) Inicie o agente:
echo       - Duplo-clique em Abrir-Hermes.bat        (CLI)
echo       - Duplo-clique em Abrir-Hermes-TUI.bat    (TUI)
echo       - Ou: powershell -File Iniciar.ps1        (menu)
echo.
echo    3) Opcional - OpenCode (editor IA):
echo       npm install -g opencode-ai  ^&^&  Abrir-OpenCode.bat
echo.
echo  Dicas: veja README.md e .env.example para todas as opcoes.
echo.

REM -- Pausa apenas se foi duplo-clique (nao quando ja esta em terminal interativo)
REM    Detecta se o parent e explorer; fallback: sempre pausa se nao houver argumento --no-pause
echo %* | findstr /i "--no-pause" >nul
if %errorlevel% neq 0 (
    pause
)
endlocal

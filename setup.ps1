# =====================================================================
#  setup.ps1 - VORTEX_AI / Hermes Agent
#
#  Instala / atualiza todas as dependencias e deixa o agente pronto para
#  uso no Windows (PowerShell 5.1+).
#
#  Uso:
#    powershell -ExecutionPolicy Bypass -File setup.ps1
#    powershell -ExecutionPolicy Bypass -File setup.ps1 -Extras "messaging,mcp"
#    powershell -ExecutionPolicy Bypass -File setup.ps1 -SkipPythonCheck
# =====================================================================
param(
    [switch]$SkipPythonCheck,
    [string]$Extras = "messaging,mcp"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
$agent = Join-Path $root "hermes-agent"

Write-Host ""
Write-Host "  VORTEX_AI / Hermes Agent - Setup" -ForegroundColor Cyan
Write-Host "  HERMES_HOME: $root" -ForegroundColor DarkGray
Write-Host ""

$env:HERMES_HOME = $root

# ------------------------------------------------------------- [1] Python
Write-Host "[1/5] Verificando Python..." -ForegroundColor Cyan
$pyOk = $false
if (-not $SkipPythonCheck) {
    $pyCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pyCmd) {
        $ver = & python -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null
        if ($ver -match '^(\d+)\.(\d+)$') {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            if (($major -eq 3) -and ($minor -ge 11) -and ($minor -le 13)) { $pyOk = $true }
        }
    }
    if (-not $pyOk) {
        Write-Host "      Instalando Python 3.12 (winget)..." -ForegroundColor Yellow
        winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements | Out-Null
        $env:Path = "$env:LOCALAPPDATA\Programs\Python\Python312;$env:Path"
        $pyOk = $true
    }
    if (-not $pyOk) {
        Write-Host "   [ERRO] Python nao disponivel. Instale em https://www.python.org/downloads/" -ForegroundColor Red
        exit 1
    }
}
Write-Host "      Python OK." -ForegroundColor Green

# ---------------------------------------------------------------- [2] uv
Write-Host "[2/5] Verificando uv..." -ForegroundColor Cyan
$uvCmd = Get-Command uv -ErrorAction SilentlyContinue
if (-not $uvCmd) {
    Write-Host "      Instalando uv (astral.sh)..." -ForegroundColor Yellow
    Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
    $uvCmd = Get-Command uv -ErrorAction SilentlyContinue
}
if (-not $uvCmd) {
    $binUv = Join-Path $root "bin\uv.exe"
    if (Test-Path $binUv) {
        Write-Host "      Usando bin\uv.exe local." -ForegroundColor DarkGray
        $uvCmd = $binUv
        function global:uv { & $binUv @args }
    }
}
if (-not $uvCmd) {
    Write-Host "   [ERRO] Nao foi possivel obter uv." -ForegroundColor Red
    exit 1
}
Write-Host "      uv OK." -ForegroundColor Green

# ------------------------------------------- [3] Sincronizar dependencias
Write-Host "[3/5] Sincronizando dependencias (uv sync)..." -ForegroundColor Cyan
$env:UV_PROJECT_ENVIRONMENT = Join-Path $agent "venv"
Push-Location $agent
try {
    if ($Extras) {
        $extraArg = @()
        $Extras -split "," | ForEach-Object {
            if ($_.Trim()) {
                $extraArg += "--extra"
                $extraArg += $_.Trim()
            }
        }
        Write-Host "      Extras: $Extras" -ForegroundColor DarkGray
        & uv sync @extraArg
    }
    else {
        & uv sync
    }
    if ($LASTEXITCODE -ne 0) { throw "uv sync falhou (codigo $LASTEXITCODE)" }
}
finally {
    Pop-Location
}

# ------------------------------------------------- [4] Gerar bin executaveis
Write-Host "[4/5] Gerando executaveis em bin/..." -ForegroundColor Cyan
$binDir = Join-Path $root "bin"
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
foreach ($name in @("hermes.exe", "hermes-agent.exe", "hermes-acp.exe")) {
    $src = Join-Path $agent "venv\Scripts\$name"
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $binDir $name) -Force
        Write-Host "      bin\$name" -ForegroundColor Green
    }
}

# ----------------------------------------------------------- [5] .env
Write-Host "[5/5] Preparando .env..." -ForegroundColor Cyan
if (-not (Test-Path (Join-Path $root ".env"))) {
    if (Test-Path (Join-Path $root ".env.example")) {
        Copy-Item (Join-Path $root ".env.example") (Join-Path $root ".env")
        Write-Host "      .env criado a partir de .env.example" -ForegroundColor Green
        Write-Host "      Edite o .env e adicione suas chaves de API." -ForegroundColor Yellow
    }
}
else {
    Write-Host "      .env ja existe (mantido)." -ForegroundColor DarkGray
}

# ------------------------------------------------------------ Concluido
Write-Host ""
Write-Host "  Concluido!" -ForegroundColor Green
Write-Host "  Agora teste:" -ForegroundColor White
Write-Host "    hermes-agent\venv\Scripts\hermes.exe --version" -ForegroundColor White
Write-Host "  Ou use os launchers:" -ForegroundColor White
Write-Host "    .\Abrir-Hermes.bat | .\Abrir-Hermes-TUI.bat | .\Iniciar.ps1" -ForegroundColor White
Write-Host ""
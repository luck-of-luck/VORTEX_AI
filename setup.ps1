# =====================================================================
#  setup.ps1 - VORTEX_AI / Hermes Agent
#
#  Instala / atualiza TODAS as dependencias e deixa o agente pronto
#  para uso imediato no Windows (PowerShell 5.1+ / 7+).
#
#  Fluxo "clone & use" para quem baixa do GitHub:
#    1) git clone https://github.com/luck-of-luck/VORTEX_AI.git
#    2) duplo-clique em setup.bat  (ou: powershell -ExecutionPolicy Bypass -File setup.ps1)
#    3) editar .env (wizard ajuda) e usar Abrir-Hermes.bat
#
#  Uso:
#    setup.bat
#    powershell -ExecutionPolicy Bypass -File setup.ps1
#    powershell -ExecutionPolicy Bypass -File setup.ps1 -Extras "messaging,mcp"
#    powershell -ExecutionPolicy Bypass -File setup.ps1 -NonInteractive
#    powershell -ExecutionPolicy Bypass -File setup.ps1 -SkipPythonCheck -WithN8nMCP
# =====================================================================
param(
    [switch]$SkipPythonCheck,
    [string]$Extras = "messaging,mcp",
    [switch]$WithN8nMCP,
    [switch]$NonInteractive,
    [switch]$SkipNodeCheck,
    [switch]$VerifyOnly
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
$agent = Join-Path $root "hermes-agent"

$env:HERMES_HOME = $root
$interactive = -not $NonInteractive -and [Environment]::UserInteractive -and (-not [Console]::IsInputRedirected)

function Write-Step($msg) { Write-Host $msg -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "      $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "      $msg" -ForegroundColor Yellow }
function Write-Info($msg) { Write-Host "      $msg" -ForegroundColor DarkGray }
function Write-Err($msg)  { Write-Host "   [ERRO] $msg" -ForegroundColor Red }

# --- Helper: detecta Python valido (3.11-3.13) entre varios comandos ---
function Get-ValidPython {
    $candidates = @("python", "python3", "py")
    foreach ($cmd in $candidates) {
        $found = Get-Command $cmd -ErrorAction SilentlyContinue
        if (-not $found) { continue }
        try {
            $verStr = & $cmd -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null
            if ($verStr -match '^(\d+)\.(\d+)$') {
                $major = [int]$Matches[1]; $minor = [int]$Matches[2]
                if (($major -eq 3) -and ($minor -ge 11) -and ($minor -le 13)) {
                    return @{ cmd=$cmd; version=$verStr; path=$found.Source }
                } else {
                    Write-Info "$cmd encontrado mas versao $verStr fora do intervalo 3.11-3.13 (ignorando)"
                }
            }
        } catch {}
    }
    # tenta py -3.12 explicitamente
    try {
        $pyLauncher = Get-Command py -ErrorAction SilentlyContinue
        if ($pyLauncher) {
            foreach ($v in @("3.13","3.12","3.11")) {
                try {
                    $verStr = & py "-$v" -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null
                    if ($verStr -match '^3\.(1[1-3])$') {
                        return @{ cmd="py -$v"; version=$verStr; path=$pyLauncher.Source }
                    }
                } catch {}
            }
        }
    } catch {}
    return $null
}

Write-Host ""
Write-Host "  VORTEX_AI / Hermes Agent - Setup" -ForegroundColor Cyan
Write-Host "  HERMES_HOME: $root" -ForegroundColor DarkGray
Write-Host "  Modo: $(if($interactive){'interativo'}else{'nao-interativo'})" -ForegroundColor DarkGray
Write-Host ""

# ------------------------------------------------------------- [1] Python
Write-Step "[1/6] Verificando Python (3.11 - 3.13)...$(if($VerifyOnly){" [VERIFY]"})"
$pyInfo = $null
if ($VerifyOnly) {
    $pyInfo = Get-ValidPython
    if ($pyInfo) { Write-Ok "Python $($pyInfo.version) OK via '$($pyInfo.cmd)'" } else { Write-Warn "Python nao encontrado (modo verify)" }
} elseif (-not $SkipPythonCheck) {
    $pyInfo = Get-ValidPython
    if ($pyInfo) {
        Write-Ok "Python $($pyInfo.version) OK via '$($pyInfo.cmd)' ($($pyInfo.path))"
    } else {
        Write-Warn "Python 3.11-3.13 nao encontrado no PATH."
        # tenta winget
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            Write-Warn "Tentando instalar Python 3.12 via winget (pode pedir permissao)..."
            try {
                winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent | Out-Null
                # atualiza PATH para a sessao
                $pyPaths = @(
                    "$env:LOCALAPPDATA\Programs\Python\Python312",
                    "$env:LOCALAPPDATA\Programs\Python\Python312\Scripts",
                    "$env:ProgramFiles\Python312",
                    "$env:ProgramFiles\Python312\Scripts"
                )
                foreach ($p in $pyPaths) { if (Test-Path $p) { $env:Path = "$p;$env:Path" } }
                Start-Sleep -Seconds 2
                $pyInfo = Get-ValidPython
                if ($pyInfo) {
                    Write-Ok "Python $($pyInfo.version) instalado via winget."
                } else {
                    Write-Warn "winget rodou mas Python ainda nao esta no PATH. Feche e reabra o terminal e rode setup novamente."
                }
            } catch {
                Write-Warn "winget falhou: $($_.Exception.Message)"
            }
        } else {
            Write-Warn "winget nao encontrado."
        }
        if (-not $pyInfo) {
            Write-Err "Python nao disponivel."
            Write-Host "      Instale manualmente uma destas opcoes:" -ForegroundColor Yellow
            Write-Host "        * https://www.python.org/downloads/  (marque 'Add to PATH')" -ForegroundColor White
            Write-Host "        * winget install Python.Python.3.12" -ForegroundColor White
            Write-Host "        * Microsoft Store -> Python 3.12" -ForegroundColor White
            Write-Host "      Depois rode novamente:  setup.bat" -ForegroundColor Yellow
            if (-not $interactive) { exit 1 }
            $resp = Read-Host "      Tentar continuar mesmo sem Python valido? (s/N)"
            if ($resp -notin @("s","S","y","Y","sim","yes")) { exit 1 }
        }
    }
} else {
    Write-Info "SkipPythonCheck ativo - pulando verificacao."
    Write-Ok "Python check ignorado."
}
if ($VerifyOnly) { }
elseif ($pyInfo) { Write-Ok "Python OK." } elseif ($SkipPythonCheck) { Write-Ok "Python check pulado." }

# ---------------------------------------------------------------- [2] uv
Write-Step "[2/6] Verificando uv (gerenciador Astral)...$(if($VerifyOnly){" [VERIFY]"})"
$uvCmd = Get-Command uv -ErrorAction SilentlyContinue
$uvPath = $null
if ($uvCmd) { $uvPath = $uvCmd.Source; Write-Info "uv encontrado em $uvPath" }

if ($VerifyOnly -and -not $uvCmd) {
    $binUv = Join-Path $root "bin\uv.exe"
    if (Test-Path $binUv) { $uvCmd = $binUv; $uvPath = $binUv; Write-Info "uv via bin\uv.exe (verify)" }
} elseif (-not $uvCmd) {
    Write-Warn "uv nao encontrado, instalando via astral.sh ..."
    try {
        # Tenta instalacao oficial
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
        # uv instala em %USERPROFILE%\.local\bin ou %USERPROFILE%\.cargo\bin
        $possibleUv = @(
            "$env:USERPROFILE\.local\bin\uv.exe",
            "$env:USERPROFILE\.cargo\bin\uv.exe",
            "$env:LOCALAPPDATA\uv\uv.exe"
        )
        foreach ($p in $possibleUv) {
            if (Test-Path $p) {
                $dir = Split-Path $p -Parent
                if ($env:Path -notlike "*$dir*") { $env:Path = "$dir;$env:Path" }
            }
        }
        $uvCmd = Get-Command uv -ErrorAction SilentlyContinue
        if ($uvCmd) { $uvPath = $uvCmd.Source }
    } catch {
        Write-Warn "Falha ao instalar uv via script: $($_.Exception.Message)"
    }
}
if (-not $uvCmd) {
    $binUv = Join-Path $root "bin\uv.exe"
    if (Test-Path $binUv) {
        Write-Info "Usando bin\uv.exe local (fallback)."
        $uvCmd = $binUv
        $uvPath = $binUv
        function global:uv { & $binUv @args }
    } else {
        # tenta copiar do cargo/local se existir
        $altUv = @("$env:USERPROFILE\.local\bin\uv.exe","$env:USERPROFILE\.cargo\bin\uv.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($altUv) {
            Write-Info "Encontrado uv em $altUv, copiando para bin\..."
            New-Item -ItemType Directory -Force -Path (Join-Path $root "bin") | Out-Null
            Copy-Item $altUv (Join-Path $root "bin\uv.exe") -Force
            $uvCmd = $altUv; $uvPath = $altUv
        }
    }
}
if (-not $uvCmd) {
    Write-Err "Nao foi possivel obter uv."
    Write-Host "      Instale manualmente:  powershell -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`"" -ForegroundColor White
    Write-Host "      Ou baixe em https://github.com/astral-sh/uv/releases" -ForegroundColor White
    exit 1
}
try {
    $uvVer = & uv --version 2>$null
    Write-Ok "uv OK ($uvVer)"
} catch {
    Write-Ok "uv OK ($uvPath)"
}

# ------------------------------------------- [3] Sincronizar dependencias
if ($VerifyOnly) {
    Write-Step "[3/6] Sincronizando dependencias (pulando em modo verify)..." 
} else {
Write-Step "[3/6] Sincronizando dependencias (uv sync) - pode levar alguns minutos na 1a vez..."
$env:UV_PROJECT_ENVIRONMENT = Join-Path $agent "venv"
if (-not (Test-Path $agent)) {
    Write-Err "Pasta hermes-agent nao encontrada em $agent"
    Write-Host "      Voce clonou o repositorio completo? git clone https://github.com/luck-of-luck/VORTEX_AI.git" -ForegroundColor Yellow
    exit 1
}
Push-Location $agent
try {
    $uvArgs = @("sync")
    if ($Extras) {
        $Extras -split "," | ForEach-Object {
            $e = $_.Trim()
            if ($e) { $uvArgs += "--extra"; $uvArgs += $e }
        }
        Write-Info "Extras: $Extras"
    }
    Write-Info "Executando: uv $($uvArgs -join ' ')"
    Write-Info "Dica: feche Hermes/Gateway/OpenCode antes do sync para liberar arquivos."
    & uv @uvArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "uv sync falhou (codigo $LASTEXITCODE). Possiveis causas:"
        Write-Host "      * Hermes/Gateway ainda rodando e travou hermes.exe (erro 32) -> feche e rode setup.bat de novo" -ForegroundColor Yellow
        Write-Host "      * Falta de internet ou Python incompatível" -ForegroundColor Yellow
        Write-Host "      Tente manualmente:" -ForegroundColor White
        Write-Host "        cd hermes-agent" -ForegroundColor Gray
        Write-Host "        uv sync --extra messaging --extra mcp --reinstall" -ForegroundColor White
        throw "uv sync falhou (codigo $LASTEXITCODE)"
    }
    Write-Ok "Dependencias sincronizadas."
}
finally {
    Pop-Location
}
} # fecha else VerifyOnly

# ------------------------------------------------- [4] Gerar bin executaveis
if ($VerifyOnly) {
    Write-Step "[4/6] Verificando bin\ ... [VERIFY]"
    $binDir = Join-Path $root "bin"
    foreach ($name in @("hermes.exe", "hermes-agent.exe", "hermes-acp.exe")) {
        $p = Join-Path $binDir $name
        $p2 = Join-Path $agent "venv\Scripts\$name"
        if ((Test-Path $p) -or (Test-Path $p2)) { Write-Ok "$name OK" } else { Write-Warn "$name faltando" }
    }
} else {
Write-Step "[4/6] Gerando executaveis em bin\ ..."
$binDir = Join-Path $root "bin"
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
$copied = 0
foreach ($name in @("hermes.exe", "hermes-agent.exe", "hermes-acp.exe")) {
    $src = Join-Path $agent "venv\Scripts\$name"
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $binDir $name) -Force
        Write-Ok "bin\$name"
        $copied++
    } else {
        Write-Warn "$name nao encontrado em venv\Scripts (pode ser normal se entrypoint mudou)"
    }
}
# garante uv no bin para setup.bat futuro offline
$uvBinDest = Join-Path $binDir "uv.exe"
if (-not (Test-Path $uvBinDest) -and $uvPath -and (Test-Path $uvPath)) {
    try { Copy-Item $uvPath $uvBinDest -Force; Write-Ok "bin\uv.exe (copiado para cache local)" } catch {}
}
if ($copied -eq 0) {
    Write-Warn "Nenhum executavel copiado. Verifique se uv sync concluiu sem erros."
} else {
    Write-Ok "Executaveis prontos."
}
}

# ----------------------------------------------------------- [5] .env
Write-Step "[5/6] Preparando .env ...$(if($VerifyOnly){" [VERIFY]"})"
$envPath = Join-Path $root ".env"
$envExample = Join-Path $root ".env.example"
if ($VerifyOnly) {
    if (-not (Test-Path $envPath)) { Write-Warn ".env nao encontrado (modo verify) - sera criado no setup normal" }
    else { Write-Info ".env existe (verify) - checando chaves..." }
} elseif (-not (Test-Path $envPath)) {
    if (Test-Path $envExample) {
        Copy-Item $envExample $envPath
        Write-Ok ".env criado a partir de .env.example"
        # tenta preencher HERMES_HOME automaticamente se vazio
        try {
            $content = Get-Content $envPath -Raw -ErrorAction SilentlyContinue
            if ($content -match "HERMES_HOME=\s*`r?`n" -or $content -match "HERMES_HOME=$") {
                $content = $content -replace "HERMES_HOME=.*", "HERMES_HOME=$root"
                Set-Content -Path $envPath -Value $content -Encoding UTF8
                Write-Info "HERMES_HOME preenchido automaticamente em .env"
            }
        } catch {}
        Write-Warn "Edite o .env e adicione sua chave de API (veja abaixo)."
    } else {
        Write-Warn ".env.example nao encontrado, criando .env minimo..."
        Set-Content -Path $envPath -Value "HERMES_HOME=$root`nCLINE_API_KEY=`nOPENROUTER_API_KEY=`n" -Encoding UTF8
    }
}
else {
    Write-Info ".env ja existe (mantido). Verificando chaves..."
}

# valida se tem pelo menos uma chave util
$hasKey = $false
$keyStatus = @{}
if (Test-Path $envPath) {
    $lines = Get-Content $envPath -ErrorAction SilentlyContinue
    foreach ($l in $lines) {
        if ($l -match "^\s*CLINE_API_KEY\s*=\s*(.+)\s*$" -and $Matches[1].Trim() -ne "") { $hasKey = $true; $keyStatus["CLINE"]="ok" }
        if ($l -match "^\s*OPENROUTER_API_KEY\s*=\s*(.+)\s*$" -and $Matches[1].Trim() -ne "") { $hasKey = $true; $keyStatus["OPENROUTER"]="ok" }
        if ($l -match "^\s*ANTHROPIC_API_KEY\s*=\s*(.+)\s*$" -and $Matches[1].Trim() -ne "") { $hasKey = $true; $keyStatus["ANTHROPIC"]="ok" }
        if ($l -match "^\s*OPENAI_API_KEY\s*=\s*(.+)\s*$" -and $Matches[1].Trim() -ne "") { $hasKey = $true; $keyStatus["OPENAI"]="ok" }
        if ($l -match "^\s*GH_TOKEN\s*=\s*(.+)\s*$" -and $Matches[1].Trim() -ne "") { $hasKey = $true; $keyStatus["GH_TOKEN"]="ok" }
        if ($l -match "^\s*COPILOT_GITHUB_TOKEN\s*=\s*(.+)\s*$" -and $Matches[1].Trim() -ne "") { $hasKey = $true; $keyStatus["COPILOT"]="ok" }
        if ($l -match "^\s*KIMI_API_KEY\s*=\s*(.+)\s*$" -and $Matches[1].Trim() -ne "") { $hasKey = $true; $keyStatus["KIMI"]="ok" }
    }
    if ($hasKey) {
        Write-Ok "Chave(s) detectada(s): $($keyStatus.Keys -join ', ')"
    } else {
        Write-Warn "Nenhuma chave de API encontrada no .env"
        Write-Host "      O agente TEM fallback gratuito, mas precisa de pelo menos UMA destas:" -ForegroundColor Yellow
        Write-Host "        * CLINE_API_KEY      -> https://app.cline.bot (Settings > API Keys) - RECOMENDADO gratis" -ForegroundColor White
        Write-Host "        * OPENROUTER_API_KEY -> https://openrouter.ai/keys (modelos :free)" -ForegroundColor White
        Write-Host "        * ANTHROPIC_API_KEY  -> https://console.anthropic.com/" -ForegroundColor White
        Write-Host "        * Ollama local       -> https://ollama.com (100% offline, veja passo 6)" -ForegroundColor White
        if ($interactive -and -not $VerifyOnly) {
            Write-Host ""
            $open = Read-Host "      Deseja abrir o .env agora para editar? (S/n)"
            if ($open -notin @("n","N","nao","no")) {
                try { notepad.exe $envPath } catch { Write-Info "Abra manualmente: $envPath" }
                Write-Host "      Dica: preencha CLINE_API_KEY ou OPENROUTER_API_KEY e salve. Depois rode Abrir-Hermes.bat" -ForegroundColor DarkGray
            }
        } elseif ($VerifyOnly) {
            Write-Info "Modo verify: nao abrindo editor. Edite manualmente: $envPath"
        } else {
            Write-Info "Edite manualmente: $envPath  (veja .env.example para exemplos)"
        }
    }
}

# ------------------------------------------------- [6] Node / OpenCode / Ollama (opcional mas recomendado)
Write-Step "[6/6] Verificando ferramentas opcionais (Node, OpenCode, Ollama)..."
$nodeOk = $false; $npmOk = $false; $opencodeOk = $false; $ollamaOk = $false
if (-not $SkipNodeCheck) {
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    $npmCmd  = Get-Command npm -ErrorAction SilentlyContinue
    if ($nodeCmd -and $npmCmd) {
        $nodeOk = $true; $npmOk = $true
        try {
            $nodeVer = & node --version 2>$null
            $npmVer  = & npm --version 2>$null
            Write-Ok "Node $nodeVer + npm $npmVer"
        } catch { Write-Ok "Node/npm encontrados" }
        $opencodeCmd = Get-Command opencode -ErrorAction SilentlyContinue
        if ($opencodeCmd) {
            $opencodeOk = $true
            try { $ocVer = & opencode --version 2>$null; Write-Ok "opencode $ocVer" } catch { Write-Ok "opencode encontrado" }
        } else {
            Write-Warn "opencode nao encontrado (opcional, mas recomendado)."
            Write-Info "Instale com: npm install -g opencode-ai   (depois use Abrir-OpenCode.bat)"
            if ($interactive -and -not $VerifyOnly) {
                $doInstall = Read-Host "      Instalar opencode agora via npm? (s/N)"
                if ($doInstall -in @("s","S","y","Y","sim","yes")) {
                    try {
                        & npm install -g opencode-ai
                        if ($LASTEXITCODE -eq 0) { $opencodeOk = $true; Write-Ok "opencode instalado!" } else { Write-Warn "npm falhou (codigo $LASTEXITCODE). Tente manualmente: npm install -g opencode-ai" }
                    } catch { Write-Warn "Falha: $($_.Exception.Message)" }
                }
            }
        }
    } else {
        Write-Warn "Node.js/npm nao encontrados (opcional, so para OpenCode)."
        Write-Info "Baixe em https://nodejs.org/ se quiser usar Abrir-OpenCode.bat"
        if ($interactive -and -not $VerifyOnly) {
            $winget = Get-Command winget -ErrorAction SilentlyContinue
            if ($winget) {
                $doNode = Read-Host "      Instalar Node.js LTS via winget agora? (s/N) [requer permissao]"
                if ($doNode -in @("s","S","y","Y","sim","yes")) {
                    try {
                        Write-Warn "Instalando Node.js LTS via winget..."
                        winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent | Out-Null
                        $env:Path = "$env:ProgramFiles\nodejs;$env:Path"
                        Start-Sleep -Seconds 2
                        $nodeCmd2 = Get-Command node -ErrorAction SilentlyContinue
                        if ($nodeCmd2) {
                            $nodeOk = $true; $npmOk = $true
                            Write-Ok "Node instalado! Reinicie o terminal se 'node --version' ainda falhar."
                            # tenta opencode em seguida
                            $doOC2 = Read-Host "      Instalar opencode agora? (s/N)"
                            if ($doOC2 -in @("s","S","y","Y")) {
                                & npm install -g opencode-ai
                                if ($LASTEXITCODE -eq 0) { $opencodeOk = $true; Write-Ok "opencode instalado!" }
                            }
                        } else { Write-Warn "winget rodou mas node ainda nao no PATH. Feche e reabra o terminal e rode setup.bat de novo." }
                    } catch { Write-Warn "winget falhou: $($_.Exception.Message) -> instale manualmente em https://nodejs.org/" }
                }
            } else {
                Write-Info "Sem winget. Baixe manualmente: https://nodejs.org/ (LTS, marque Add to PATH)"
            }
        }
    }
} else {
    Write-Info "SkipNodeCheck ativo."
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCmd) { $nodeOk = $true }
}

# Ollama (100% gratis/offline) + LM Studio
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue
if ($ollamaCmd) {
    $ollamaOk = $true
    Write-Ok "Ollama encontrado ($($ollamaCmd.Source))"
    try {
        $models = & ollama list 2>$null | Out-String
        if ($models -match "qwen|llama|deepseek|phi|gemma|mistral|nomic" ) {
            Write-Ok "Modelos Ollama ja instalados:"
            $models -split "`n" | Select-Object -First 5 | ForEach-Object { if ($_.Trim()) { Write-Info "  $_".TrimEnd() } }
        } else {
            Write-Warn "Ollama instalado mas nenhum modelo encontrado."
            Write-Info "Baixe um modelo gratis: ollama pull qwen2.5-coder:32b  (ou: ollama pull qwen2.5:14b para PCs modestos)"
            if ($interactive -and -not $VerifyOnly -and -not $hasKey) {
                Write-Host "      Sem chave API, Ollama e sua melhor opcao 100% gratis/offline." -ForegroundColor Yellow
                $pull = Read-Host "      Baixar qwen2.5-coder:14b agora? (s/N) [pode levar minutos, ~8GB]"
                if ($pull -in @("s","S","y","Y")) {
                    Write-Warn "Baixando qwen2.5-coder:14b (aguarde)..."
                    & ollama pull qwen2.5-coder:14b
                    if ($LASTEXITCODE -eq 0) { Write-Ok "Modelo pronto! Ja da para usar sem chave API." }
                    else { Write-Warn "Falha no pull. Tente: ollama pull qwen2.5:14b" }
                }
            }
        }
        try {
            $resp = Invoke-WebRequest -Uri http://127.0.0.1:11434/api/tags -TimeoutSec 3 -UseBasicParsing -ErrorAction SilentlyContinue
            if ($resp -and $resp.StatusCode -eq 200) { Write-Ok "Ollama servidor rodando (http://127.0.0.1:11434)" }
            else { Write-Warn "Ollama instalado mas servidor nao responde. Rode: ollama serve" }
        } catch { Write-Info "Ollama servidor nao detectado - inicie com: ollama serve (ou reinicie o PC)" }
    } catch {}
} else {
        if (-not $hasKey) {
        Write-Warn "Ollama nao encontrado - recomendado para uso 100% gratis/offline (sem chave)."
        Write-Info "Instale em https://ollama.com/  depois: ollama pull qwen2.5-coder:32b  e  ollama serve"
        if ($interactive -and -not $VerifyOnly) {
            $winget2 = Get-Command winget -ErrorAction SilentlyContinue
            if ($winget2) {
                $doOll = Read-Host "      Instalar Ollama via winget agora? (s/N)"
                if ($doOll -in @("s","S","y","Y")) {
                    try {
                        winget install -e --id Ollama.Ollama --accept-source-agreements --accept-package-agreements --silent | Out-Null
                        Write-Ok "Ollama instalado! Feche e reabra o terminal, depois: ollama pull qwen2.5-coder:32b"
                        $ollamaOk = $true
                    } catch { Write-Warn "winget falhou: $($_.Exception.Message) -> https://ollama.com/" }
                }
            }
        }
    } else {
        Write-Info "Ollama nao encontrado (opcional, fallback local). https://ollama.com/"
    }
    Write-Info "LM Studio alternativo (app desktop): https://lmstudio.ai/ -> Start Server em :1234 (provider lmstudio-local)"
}
# Git check (para verificacao final)
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
$gitOk = $null -ne $gitCmd

# ------------------------------------------------------- [extra] n8n MCP (opcional)
if ($WithN8nMCP) {
    Write-Step "[extra] Instalando n8n MCP (hermes mcp install n8n)..."
    $hermBin = Join-Path $root "bin\hermes.exe"
    if (-not (Test-Path $hermBin)) { $hermBin = Join-Path $agent "venv\Scripts\hermes.exe" }
    if (Test-Path $hermBin) {
        & $hermBin mcp install n8n
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "n8n MCP nao concluido automaticamente. Rode: hermes mcp install n8n"
        }
        else {
            Write-Ok "n8n MCP instalado. Preencha N8N_API_KEY no .env se necessario."
        }
    }
    else {
        Write-Warn "hermes.exe nao encontrado; instale n8n manualmente depois."
    }
}

# ------------------------------------------------------------ Validacao final - VERIFICACAO COMPLETA para quem nao tem nada
Write-Step "[verificacao] Verificando instalacao completa (para quem nao tinha nada)..."
$hermTest = Join-Path $agent "venv\Scripts\hermes.exe"
if (-not (Test-Path $hermTest)) { $hermTest = Join-Path $root "bin\hermes.exe" }
$hermVerOut = ""; $hermOk = $false
if (Test-Path $hermTest) {
    try {
        $verOut = & $hermTest --version 2>&1 | Out-String
        $verOut = $verOut.Trim()
        if ($verOut) { $hermVerOut = $verOut; $hermOk = $true; Write-Ok "hermes --version: $verOut" }
        else { Write-Warn "hermes executou mas sem saida de versao" }
    } catch { Write-Warn "Falha ao testar hermes --version: $($_.Exception.Message)" }
} else { Write-Warn "hermes.exe nao encontrado para validacao." }

# Coleta status para tabela final
$checks = @()
function Add-Check($nome, $ok, $detalhe) {
    $icon = if ($ok) { "[OK]" } else { "[!!]" }
    $color = if ($ok) { "Green" } else { "Red" }
    $checks += @{ nome=$nome; ok=$ok; detalhe=$detalhe; icon=$icon; color=$color }
    return @{ nome=$nome; ok=$ok; detalhe=$detalhe; icon=$icon; color=$color }
}
$null = $checks  # init
$checks = @()
$pyOkFinal = $null -ne $pyInfo -or $SkipPythonCheck
$checks += @{ nome="Python 3.11-3.13"; ok=$pyOkFinal; detalhe=if($pyInfo){"$($pyInfo.version) via $($pyInfo.cmd)"}else{if($SkipPythonCheck){"ignorado"}else{"faltando"}} }
$checks += @{ nome="uv (Astral)"; ok=($null -ne $uvCmd); detalhe=if($uvCmd){try{& uv --version 2>$null}catch{$uvPath}}else{"faltando"} }
$checks += @{ nome="hermes-agent venv"; ok=$hermOk; detalhe=if($hermOk){$hermVerOut}else{"falhou - rode setup.bat de novo"} }
$checks += @{ nome=".env"; ok=(Test-Path $envPath); detalhe=if(Test-Path $envPath){if($hasKey){"chave: $($keyStatus.Keys -join ', ')"}else{"sem chave (precisa 1)"}}else{"faltando"} }
$checks += @{ nome="Chave API ou Ollama"; ok=($hasKey -or $ollamaOk); detalhe=if($hasKey){"chave OK ($($keyStatus.Keys -join ','))"}elseif($ollamaOk){"Ollama local OK"}else{"FALTA: adicione CLINE_API_KEY/OPENROUTER_API_KEY ou instale Ollama"} }
$checks += @{ nome="Node.js + npm"; ok=$nodeOk; detalhe=if($nodeOk){try{& node --version 2>$null}catch{"ok"}}else{"opcional - para OpenCode (https://nodejs.org/)"} }
$checks += @{ nome="opencode"; ok=$opencodeOk; detalhe=if($opencodeOk){try{& opencode --version 2>$null}catch{"ok"}}else{if($nodeOk){"nao instalado: npm install -g opencode-ai"}else{"precisa Node primeiro"}} }
$checks += @{ nome="Ollama local"; ok=$ollamaOk; detalhe=if($ollamaOk){"instalado (fallback 100% offline)"}else{"opcional - https://ollama.com/"} }
$checks += @{ nome="Git"; ok=$gitOk; detalhe=if($gitOk){try{& git --version 2>$null}catch{"ok"}}else{"recomendado para clone/commit"} }
$checks += @{ nome="config.yaml"; ok=(Test-Path (Join-Path $root "config.yaml")); detalhe="fallback inteligente configurado" }
# --- VORTEX: opencode + Hermes bridge ---
$opencodeJsonOk = Test-Path (Join-Path $root "opencode.jsonc")
$checks += @{ nome="opencode.jsonc"; ok=$opencodeJsonOk; detalhe=if($opencodeJsonOk){"Hermes MCP + ollama/lmstudio"}else{"faltando - git pull?"} }
$vortexSkillOk = Test-Path (Join-Path $root ".opencode\skills\vortex-hermes\SKILL.md")
$checks += @{ nome="vortex-hermes skill"; ok=$vortexSkillOk; detalhe=if($vortexSkillOk){"bridge opencode+Hermes"}else{"faltando"} }
# testa hermes MCP serve rapidamente (se hermes ok)
$hermesMcpOk = $false
if ($hermOk) {
    try {
        $mcpHelp = & $hermTest mcp --help 2>&1 | Out-String
        if ($mcpHelp -match "mcp") { $hermesMcpOk = $true }
    } catch {}
}
$checks += @{ nome="Hermes MCP"; ok=$hermesMcpOk; detalhe=if($hermesMcpOk){"bin/hermes.exe mcp serve OK"}else{"falhou - .env/config?" } }
# --- PROTON JARVIS ---
$protonOk = Test-Path (Join-Path $root "proton\index.html")
$checks += @{ nome="PROTON JARVIS"; ok=$protonOk; detalhe=if($protonOk){"RTX + neon + fluid (Abrir-PROTON.bat)"}else{"faltando - git pull"} }
$protonBatOk = Test-Path (Join-Path $root "Abrir-PROTON.bat")
$checks += @{ nome="Abrir-PROTON.bat"; ok=$protonBatOk; detalhe=if($protonBatOk){"launcher PROTON"}else{"faltando"} }

Write-Host ""
Write-Host "  ----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "   VERIFICACAO FINAL - VORTEX_AI" -ForegroundColor Cyan
Write-Host "  ----------------------------------------------------------" -ForegroundColor Cyan
$okCount = 0
foreach ($c in $checks) {
    $icon = if ($c.ok) { "[OK]" } else { "[!!]" }
    $col = if ($c.ok) { "Green" } else { if ($c.nome -match "Node|opencode|Ollama|Git") { "DarkGray" } else { "Red" } }
    if ($c.ok) { $okCount++ }
    Write-Host ("   {0} {1,-22} : {2}" -f $icon, $c.nome, $c.detalhe) -ForegroundColor $col
}
Write-Host "  ----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "   Resultado: $okCount/$($checks.Count) verificacoes OK" -ForegroundColor $(if($okCount -ge 5){"Green"}else{"Yellow"})
if (-not $hasKey -and -not $ollamaOk) {
    Write-Host ""
    Write-Host "   [AVISO] ACAO NECESSARIA: sem chave API e sem Ollama, o agente NAO vai responder." -ForegroundColor Yellow
    Write-Host "      Escolha UMA:" -ForegroundColor Yellow
    Write-Host "        1) Grátis (Cline): https://app.cline.bot -> Settings > API Keys -> cole em .env CLINE_API_KEY" -ForegroundColor White
    Write-Host "        2) Grátis (OpenRouter): https://openrouter.ai/keys -> cole em .env OPENROUTER_API_KEY" -ForegroundColor White
    Write-Host "        3) 100% offline: https://ollama.com -> instale -> ollama pull qwen2.5-coder:32b -> ollama serve" -ForegroundColor White
    Write-Host "      Depois: Abrir-Hermes.bat" -ForegroundColor White
} elseif ($hasKey -or $ollamaOk) {
    Write-Host "   [OK] Pronto para usar! Chave/Ollama ok." -ForegroundColor Green
}
Write-Host ""

if ($VerifyOnly) {
    Write-Host "  Modo --VerifyOnly: apenas verificacao, sem reinstalar." -ForegroundColor DarkGray
    exit 0
}

# ------------------------------------------------------------ Concluido
Write-Host "  ==========================================================" -ForegroundColor Green
Write-Host "   Concluido! VORTEX_AI pronto." -ForegroundColor Green
Write-Host "  ==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Como usar agora (1 clique):" -ForegroundColor White
Write-Host "    * Duplo-clique em Abrir-Hermes.bat         -> CLI (chat)" -ForegroundColor White
Write-Host "    * Duplo-clique em Abrir-Hermes-TUI.bat     -> TUI (interface completa)" -ForegroundColor White
Write-Host "    * Duplo-clique em Iniciar.ps1              -> menu interativo (8 opcoes)" -ForegroundColor White
Write-Host "    * Terminal: hermes-agent\venv\Scripts\hermes.exe --tui" -ForegroundColor Gray
Write-Host ""
if (-not $hasKey -and -not $ollamaOk) {
    Write-Host "  ATENCAO: Configure sua chave antes de usar (veja verificacao acima)." -ForegroundColor Yellow
    Write-Host ""
}
Write-Host "  Para quem nao tinha NADA instalado, o setup ja instalou/verificou:" -ForegroundColor Cyan
Write-Host "    * Python 3.12 + uv + hermes-agent (obrigatorio) -> OK se 3 primeiros [OK]" -ForegroundColor DarkGray
Write-Host "    * Node/opencode (opcional, para editor IA) -> se [!!] instale Node e rode setup.bat de novo" -ForegroundColor DarkGray
Write-Host "    * Ollama/LM Studio (opcional, 100% offline) -> se [!!] e sem chave, instale para usar sem internet" -ForegroundColor DarkGray
Write-Host "  Re-verificar a qualquer hora:" -ForegroundColor DarkGray
Write-Host "    powershell -File setup.ps1 -VerifyOnly   ou   setup.bat --verify" -ForegroundColor White
Write-Host ""
Write-Host "  Dicas de potencia:" -ForegroundColor Cyan
Write-Host "    * Navegador: peca 'navegue em X e extraia Y' - usa Chrome local automatico." -ForegroundColor DarkGray
Write-Host "    * Modelos locais gratis: Ollama (ollama.com) ja configurado em config.yaml" -ForegroundColor DarkGray
Write-Host "      Ex.: ollama pull qwen2.5-coder:32b  (provider ollama-local)" -ForegroundColor DarkGray
Write-Host "    * LM Studio: app -> Developer -> Start Server (porta 1234, provider lmstudio-local)" -ForegroundColor DarkGray
Write-Host "    * Outras IAs no fallback automatico: Copilot (GH_TOKEN), Claude, Kimi - veja .env.example" -ForegroundColor DarkGray
Write-Host "    * n8n: se usou -WithN8nMCP, gere API key em n8n > Settings > API" -ForegroundColor DarkGray
Write-Host "    * Gateway (Telegram etc): hermes gateway setup  +  gateway run" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Documentacao: README.md  |  Config: config.yaml  |  Chaves: .env  |  Logs: logs/" -ForegroundColor DarkGray
Write-Host ""

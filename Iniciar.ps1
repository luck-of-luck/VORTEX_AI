# Iniciar.ps1 - Launcher interativo para Hermes + OpenCode
# Uso: clique direito -> Executar com PowerShell, ou: powershell -ExecutionPolicy Bypass -File Iniciar.ps1

$Host.UI.RawUI.WindowTitle = "Hermes + OpenCode - Launcher"
$root = $PSScriptRoot
$agent = Join-Path $root "hermes-agent"
$env:HERMES_HOME = $root

function Show-Menu {
  Clear-Host
  Write-Host "==========================================" -ForegroundColor Cyan
  Write-Host "  VORTEX_AI - Hermes + OpenCode" -ForegroundColor White
  Write-Host "  Raiz: $root" -ForegroundColor DarkGray
  Write-Host "==========================================" -ForegroundColor Cyan
  Write-Host ""
  $hasHermes = (Test-Path "$root\hermes-agent\venv\Scripts\hermes.exe") -or (Test-Path "$root\bin\hermes.exe")
  $hasEnv = Test-Path "$root\.env"
  $hasNode = $null -ne (Get-Command node -ErrorAction SilentlyContinue)
  if (-not $hasHermes) { Write-Host "  [!] Setup nao executado - escolha 7 para instalar" -ForegroundColor Red }
  elseif (-not $hasEnv) { Write-Host "  [!] .env nao encontrado - rode setup.bat" -ForegroundColor Yellow }
  Write-Host ""
  Write-Host "  1) OpenCode na RAIZ (hermes/)" -ForegroundColor Green -NoNewline; Write-Host "  -> opencode.jsonc + mcp.hermes" -ForegroundColor DarkGray
  Write-Host "  2) OpenCode no AGENT (hermes-agent/)" -ForegroundColor Green -NoNewline; Write-Host "  -> codigo fonte" -ForegroundColor DarkGray
  Write-Host "  3) Hermes CLI" -ForegroundColor Yellow
  Write-Host "  4) Hermes TUI (Ink)" -ForegroundColor Yellow
  Write-Host "  5) Hermes Gateway (mensagens)" -ForegroundColor Magenta
  Write-Host "  6) Abrir pasta no Explorer" -ForegroundColor Gray
  Write-Host "  7) Setup / Reinstalar dependencias" -ForegroundColor Cyan -NoNewline; Write-Host "  -> setup.bat" -ForegroundColor DarkGray
  Write-Host "  8) Editar .env (chaves API)" -ForegroundColor DarkCyan
  Write-Host "  9) PROTON — JARVIS (RTX + Neon)" -ForegroundColor Magenta -NoNewline; Write-Host "  -> proton/index.html" -ForegroundColor DarkGray
  Write-Host "  0) Sair" -ForegroundColor DarkGray
  Write-Host ""
  if (-not $hasNode) { Write-Host "  (Node nao encontrado - OpenCode precisa de Node.js https://nodejs.org/)" -ForegroundColor DarkGray }
}

function Test-Opencode {
  try { $v = & opencode --version 2>$null; if ($LASTEXITCODE -eq 0) { return $true } } catch {}
  # fallback via npm
  $opencodeCmd = "opencode.cmd"
  return Test-Path $opencodeCmd
}

function Get-HermesExe {
  $candidates = @(
    (Join-Path $root "hermes-agent\venv\Scripts\hermes.exe"),
    (Join-Path $root "bin\hermes.exe")
  )
  foreach ($c in $candidates) {
    if (Test-Path $c) { return $c }
  }
  Write-Host "hermes.exe nao encontrado. Rode setup.ps1 antes." -ForegroundColor Red
  return $null
}

while ($true) {
  Show-Menu
  $c = Read-Host "Escolha [0-9]"
  switch ($c) {
    "1" {
      Set-Location $root
      Write-Host "`nIniciando OpenCode em $root ..." -ForegroundColor Green
      if (Test-Path "$root\opencode.jsonc") { Write-Host "  config: $root\opencode.jsonc" -ForegroundColor DarkGray }
      try { & opencode } catch { & "opencode.cmd" }
      Pause
    }
    "2" {
      Set-Location $agent
      Write-Host "`nIniciando OpenCode em $agent ..." -ForegroundColor Green
      try { & opencode } catch { & "opencode.cmd" }
      Pause
    }
    "3" {
      Set-Location $agent
      Write-Host "`nIniciando Hermes CLI ..." -ForegroundColor Yellow
      $exe = Get-HermesExe
      if ($exe) { & $exe }
      Pause
    }
    "4" {
      Set-Location $agent
      Write-Host "`nIniciando Hermes TUI ..." -ForegroundColor Yellow
      $exe = Get-HermesExe
      if ($exe) { & $exe --tui }
      Pause
    }
    "5" {
      Set-Location $agent
      Write-Host "`nIniciando Hermes Gateway (Ctrl+C para parar)..." -ForegroundColor Magenta
      $exe = Get-HermesExe
      if ($exe) { & $exe gateway run }
      Pause
    }
    "6" { explorer.exe $root }
    "7" {
      Write-Host "`nExecutando setup.ps1 ..." -ForegroundColor Cyan
      & powershell -ExecutionPolicy Bypass -File "$root\setup.ps1"
      Pause
    }
    "8" {
      $envFile = Join-Path $root ".env"
      if (Test-Path $envFile) {
        Write-Host "`nAbrindo .env em $envFile ..." -ForegroundColor Cyan
        try { notepad.exe $envFile } catch { Write-Host "Abra manualmente: $envFile" -ForegroundColor Yellow }
      } else {
        Write-Host ".env nao encontrado. Rode setup (opcao 7) primeiro." -ForegroundColor Yellow
        if (Test-Path "$root\.env.example") { Write-Host "Modelo: $root\.env.example" -ForegroundColor DarkGray }
      }
      Pause
    }
    "9" {
      $proton = Join-Path $root "proton\index.html"
      if (Test-Path $proton) {
        Write-Host "`nAbrindo PROTON — JARVIS ..." -ForegroundColor Magenta
        Write-Host "  $proton" -ForegroundColor DarkGray
        try { Start-Process $proton } catch { Write-Host "Abra manualmente: $proton" -ForegroundColor Yellow }
      } else {
        Write-Host "proton\index.html nao encontrado. Faça git pull." -ForegroundColor Yellow
      }
      Pause
    }
    "0" { return }
    default { Write-Host "Opcao invalida" -ForegroundColor Red; Start-Sleep 1 }
  }
}
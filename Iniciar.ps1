# Iniciar.ps1 - Launcher interativo para Hermes + OpenCode
# Uso: clique direito -> Executar com PowerShell, ou: powershell -ExecutionPolicy Bypass -File Iniciar.ps1

$Host.UI.RawUI.WindowTitle = "Hermes + OpenCode - Launcher"
$root = $PSScriptRoot
$agent = Join-Path $root "hermes-agent"
$env:HERMES_HOME = $root

function Show-Menu {
  Clear-Host
  Write-Host "==========================================" -ForegroundColor Cyan
  Write-Host "  Hermes + OpenCode - Raiz: $root" -ForegroundColor White
  Write-Host "==========================================" -ForegroundColor Cyan
  Write-Host ""
  Write-Host "  1) OpenCode na RAIZ (hermes/)" -ForegroundColor Green -NoNewline; Write-Host "  -> opencode.jsonc + mcp.hermes"
  Write-Host "  2) OpenCode no AGENT (hermes-agent/)" -ForegroundColor Green -NoNewline; Write-Host "  -> codigo fonte"
  Write-Host "  3) Hermes CLI" -ForegroundColor Yellow
  Write-Host "  4) Hermes TUI (Ink)" -ForegroundColor Yellow
  Write-Host "  5) Hermes Gateway (mensagens)" -ForegroundColor Magenta
  Write-Host "  6) Abrir pasta no Explorer" -ForegroundColor Gray
  Write-Host "  0) Sair" -ForegroundColor DarkGray
  Write-Host ""
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
  $c = Read-Host "Escolha [0-6]"
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
    "0" { return }
    default { Write-Host "Opcao invalida" -ForegroundColor Red; Start-Sleep 1 }
  }
}
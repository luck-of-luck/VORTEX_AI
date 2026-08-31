# VORTEX_AI v1.2.0 — OpenCode + Hermes Skills + MCP

> **Data:** 2026-08-31  
> **Tags:** `v1.1.0` (setup fresh-install) + `v1.2.0` (opencode bridge)

## O que há de novo

### OpenCode + Hermes integrado (bridge `vortex-hermes`)
- **`opencode.jsonc` completo** na raiz (antes só `hermes` MCP):
  - `instructions`: `AGENTS.md` + `SOUL.md` + `hermes-agent/AGENTS.md`
  - `references`: `hermes-agent`, `hermes-config`, `hermes-skills` (80+), `vortex-skills`, `opencode-skill`, `vortex-bridge`
  - `mcp.hermes` **enabled** `bin/hermes.exe mcp serve` — 80+ skills Hermes dentro do opencode
  - `mcp.context7` **disabled** `https://mcp.context7.com/mcp` — `enabled:true` para docs atualizadas
  - `mcp.n8n` **disabled** `hermes-agent/venv/Scripts/python.exe` — habilita após `hermes mcp install n8n`
  - `providers`: `cline` (5 modelos), `openrouter` (`openrouter/free`, `z-ai/glm-5.2:free`), `ollama-local` (`qwen2.5-coder:32b` etc. `:11434/v1`), `lmstudio-local` (`:1234/v1`)

- **`.opencode/skills/vortex-hermes/SKILL.md`** (148 linhas):
  - Quando usar, arquitetura VORTEX, MCP hermes/context7/n8n, 80+ skills, provider chain espelhada do `config.yaml`, delegação cruzada `Hermes ↔ OpenCode` (`opencode run` vs `hermes_*` MCP), pitfalls (prompt caching, `%LOCALAPPDATA%\hermes`, reiniciar opencode)

### Setup `fresh-install` + verificação 13 checks
- `setup.bat` 1-clique (detecta `pwsh`/`powershell`, alias `--verify` → `-VerifyOnly`)
- `setup.ps1` com `-VerifyOnly`, auto Node/Ollama via `winget`, 10 → 13 checks:
  `Python`, `uv`, `hermes`, `.env`, `Chave/Ollama`, `Node`, `opencode`, `Ollama`, `Git`, `config.yaml`, `opencode.jsonc`, `vortex-hermes skill`, `Hermes MCP`
- `setup.bat --verify` / `powershell -File setup.ps1 -VerifyOnly` para quem não tinha nada

### Fallback IA 100% grátis/offline (v1.1.0)
- `config.yaml`: `openrouter/free` + `z-ai/glm-5.2:free` no topo OpenRouter `:free`
- `.env.example` guiado, `README` fluxo `clone & use` Opção A/B

## Verificado
```bash
opencode --version          # 1.18.23
opencode mcp list           # hermes ✓ connected
python -c "import json; json.load(open('opencode.jsonc'))"  # JSON OK
powershell -File setup.ps1 -VerifyOnly  # 13/13 OK
```

## Como usar quem baixou do GitHub
```powershell
git clone https://github.com/luck-of-luck/VORTEX_AI.git
cd VORTEX_AI
setup.bat          # ou setup.bat --verify
notepad .env       # CLINE_API_KEY ou OPENROUTER_API_KEY ou ollama
Abrir-OpenCode.bat # opencode com Hermes MCP
# no opencode: "use vortex-hermes skill"
```

> Após editar `opencode.jsonc`, **reinicie o opencode** (não hot-reload). Windows home: `%LOCALAPPDATA%\hermes`.

## Commits
- `74516a3` feat(setup): clone & use com setup.bat + fallback IA
- `520e17c` feat(setup): verificação fresh-install + auto Node/Ollama + --verify
- `8267dba` feat(opencode): Hermes integrado no OpenCode com skills + MCP

## Próximos passos
- Criar Release no GitHub: https://github.com/luck-of-luck/VORTEX_AI/releases → Draft new release → Tag `v1.2.0` → Title `VORTEX_AI v1.2.0` → copie este arquivo
- Ou instale `gh`: `winget install GitHub.cli` → `gh auth login` → `gh release create v1.2.0 --title "VORTEX_AI v1.2.0" --notes-file RELEASE_v1.2.0.md`

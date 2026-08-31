---
name: vortex-hermes
description: Bridge opencode+Hermes com skills e MCP para VORTEX_AI.
---

# VORTEX-Hermes Bridge — OpenCode + Hermes Agent

> **Leia este skill SEMPRE que for codar no VORTEX_AI via opencode.** Ele conecta o editor IA (opencode) ao agente autônomo (Hermes) com todas as skills e MCPs.

## Quando Usar

- Você está no repo `VORTEX_AI` (raiz `C:\Users\... \hermes` ou clone `VORTEX_AI/`)
- Precisa editar `hermes-agent/`, `config.yaml`, `opencode.jsonc`, `setup.ps1`, skills, gateway, cron, kanban
- Quer usar skills Hermes (80+) dentro do opencode (via MCP `hermes`)
- Quer delegar para Hermes como worker (`opencode` → `hermes`, ou `hermes` → `opencode`)

## Arquitetura VORTEX_AI

```
VORTEX_AI/  (repo que o usuário clona)
├─ hermes-agent/          # upstream Nous Research (não edite sem necessidade)
│  ├─ skills/             # 16 categorias, 80+ skills (github, opencode, vortex, etc.)
│  ├─ plugins/            # plugins (memory, model-providers, kanban...)
│  ├─ tools/              # tools nativas (terminal, browser, delegate_task...)
│  ├─ gateway/            # gateway Telegram/Discord/Slack...
│  └─ opencode.jsonc      # config opencode do upstream (referencia ../bin/hermes.exe)
├─ .opencode/skills/vortex-hermes/  # ← este skill (bridge VORTEX)
├─ bin/hermes.exe         # binário gerado por setup.ps1 (venv\Scripts\hermes.exe)
├─ opencode.jsonc         # CONFIG PRINCIPAL VORTEX — opencode na RAIZ (usa bin/hermes.exe mcp serve)
├─ config.yaml            # fallback inteligente (Cline → OpenRouter :free → Ollama)
├─ setup.bat / setup.ps1  # instalador 1-clique + verificação 10 checks
└─ SOUL.md / AGENTS.md    # persona e invariants (prompt caching sagrado)
```

**Windows home:** `%LOCALAPPDATA%\hermes` (`C:\Users\lucas\AppData\Local\hermes`), **não** `~/.hermes`.
Após editar `opencode.jsonc`, **reinicie o opencode** (config não hot-reload).

## MCP — Hermes dentro do OpenCode

`opencode.jsonc` já declara:

```json
"mcp": {
  "hermes": {
    "type": "local",
    "command": ["bin/hermes.exe", "mcp", "serve"],
    "enabled": true
  },
  "context7": { "type": "remote", "url": "https://mcp.context7.com/mcp", "enabled": false },
  "n8n": { "type": "local", "command": ["hermes-agent/venv/Scripts/python.exe", "../mcp-installs/n8n/server.py"], "enabled": false }
}
```

**Verificar:**
```bash
opencode mcp list                 # deve mostrar hermes conectado
opencode mcp invoke hermes tools  # lista skills/tools Hermes
```

**Habilitar opcionais:**
- `context7`: mude `"enabled": false` → `true` em `opencode.jsonc` e reinicie opencode. Para docs atualizadas: `mcp invoke context7 resolve-library-id` + `query-docs`.
- `n8n`: instale `hermes mcp install n8n` (ou `setup.ps1 -WithN8nMCP`), depois habilite em `opencode.jsonc` e ajuste o `command` para o `.venv` correto (Windows: `hermes-agent/venv/Scripts/python.exe`, Linux/Mac: `.../.venv/bin/python`).

**Hermes tem 80+ skills via MCP.** Exemplos que o opencode pode chamar:
- `vortex/ai-app-orchestration` — delegar para Claude/Cursor/Kimi via terminal
- `vortex/git-commit-workflow` — commits no branch atual (conventional commits)
- `vortex/visual-browser-user-protocol` — navegar como usuário de 1ª vez com visão
- `autonomous-ai-agents/opencode` — este oposto: Hermes delegando para opencode (`opencode run`)
- `github/*` — codebase-inspection, pr-workflow
- `productivity/*` — notion, pdf, xlsx, etc.

## Skills — Como Usar

Skills são **instruções** que o modelo deve ler antes de agir. No opencode, o `instructions` já carrega `AGENTS.md` + `SOUL.md` + `hermes-agent/AGENTS.md`. As `references` deixam o catálogo à mão:

- `hermes-skills` → `./hermes-agent/skills` (todas as skills)
- `vortex-skills` → `./hermes-agent/skills/vortex` (4 skills VORTEX)
- `opencode-skill` → `./hermes-agent/skills/autonomous-ai-agents/opencode`

**Procedimento:**
1. Antes de editar `hermes-agent/*`, leia `hermes-agent/AGENTS.md` (narrow waist, prompt caching, Footprint Ladder).
2. Escolha a skill: `skills/vortex/ai-app-orchestration/SKILL.md` para delegar, `visual-browser-user-protocol` para browser, etc.
3. Via MCP `hermes`, invoque a skill: `hermes_skill_list` / `hermes_skill_load` / `hermes_run_skill` (nomes variam conforme MCP; use `mcp list` para confirmar).
4. Se a skill precisar de `.env` (ex: `CLINE_API_KEY`, `N8N_API_KEY`), verifique `config.yaml` e `.env.example`.

## Provider Chain — Mesma do Hermes

`opencode.jsonc` espelha `config.yaml` (fallback inteligente):

| Ordem | Provider | Modelo | Chave |
|-------|----------|--------|-------|
| 1 | `cline` | `minimax/minimax-m2.5` | `CLINE_API_KEY` |
| 2 | `cline` | `deepseek/deepseek-chat` | `CLINE_API_KEY` |
| 3-5 | `cline` | ClinePass | `CLINE_API_KEY` |
| 6+ | `openrouter` | `openrouter/free`, `z-ai/glm-5.2:free`, etc. | `OPENROUTER_API_KEY` |
| local | `ollama-local` | `qwen2.5-coder:32b` | `ollama serve` |
| local | `lmstudio-local` | `qwen2.5-coder-14b-instruct` | LM Studio `:1234` |

Troque com `/model` no opencode ou edite `opencode.jsonc` → reinicie. O `setup.ps1 -VerifyOnly` valida tudo (10 checks).

## Delegação Cruzada (Hermes ↔ OpenCode)

**OpenCode → Hermes (este skill):**
- Via MCP `hermes`: `hermes_chat`, `hermes_delegate_task`, `hermes_browser_*`
- Hermes roda com `HERMES_HOME` da raiz VORTEX e tem acesso a `config.yaml` + `.env`

**Hermes → OpenCode (oposto):**
- Hermes tem skill `autonomous-ai-agents/opencode` em `%LOCALAPPDATA%\hermes\skills\opencode\SKILL.md`
- Hermes delega via `terminal`/`delegate_task`:
  ```bash
  opencode run "implemente X"        # headless, um por vez
  opencode run "fix Y" -f file.ts    # com contexto
  ```
- Hermes sabe que `opencode mcp serve` vive em `bin/hermes.exe`

## Pitfalls

- **Prompt caching sagrado:** não troque `toolsets` mid-conversation, não mute contexto passado.
- **Não quebre `hermes-agent/` sem motivo:** prefira CLI+skill > plugin > MCP > core tool (Footprint Ladder). Leia `hermes-agent/AGENTS.md` antes.
- **Windows home:** use `%LOCALAPPDATA%\hermes`, não `~/.hermes`. `get_hermes_home()` no código, `display_hermes_home()` para logs.
- **MCP hermes desabilitado?** Verifique `opencode.jsonc` → `"hermes": {"enabled": true}` e `bin/hermes.exe` existe (rode `setup.bat`).
- **Skills não aparecem?** `opencode mcp list` deve mostrar `hermes`. Se não, `hermes mcp serve` falhou — cheque `.env` tem 1 chave e `config.yaml` válido (`python -c "import yaml; yaml.safe_load(open('config.yaml'))"`).
- **Após editar `opencode.jsonc`, reinicie opencode.**
- **Testes Hermes:** `scripts/run_tests.sh` (não `pytest` direto), hermético `HERMES_HOME` temp.

## Quick Reference

```bash
# Verificar bridge
opencode mcp list
opencode --version
bin/hermes.exe --version
powershell -File setup.ps1 -VerifyOnly

# Usar Hermes via opencode (MCP)
# No prompt do opencode: "use hermes to ..."
# Ou via tool: mcp_invoke hermes <tool>

# Usar opencode via Hermes (skill)
# No Hermes: "delegate to opencode: opencode run '...'"
```

## Verificação

- `opencode.jsonc` JSON OK? `python -c "import json; json.load(open('opencode.jsonc'))"`
- `hermes` MCP conectado? `opencode mcp list` → `hermes: connected`
- Skills list? `hermes mcp invoke hermes skill_list` ou `terminal: bin/hermes.exe skills list`
- `setup.ps1 -VerifyOnly` → `10/10 OK`?

# 🌌 VORTEX AI — Hermes Agent

> **Agente de IA autônomo, local-first e pronto para produção.**
> Baseado no [Hermes Agent](https://github.com/NousResearch/hermes-agent) (Nous Research),
> empacotado com configurações, launchers e um fluxo "*clone & use*" para Windows.

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/Licen%C3%A7a-MIT-blue.svg" alt="Licença MIT"></a>
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-3.11%20%E2%80%93%203.13-blue.svg?logo=python&logoColor=white" alt="Python 3.11–3.13"></a>
  <a href="https://learn.microsoft.com/pt-br/powershell/"><img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE.svg?logo=powershell&logoColor=white" alt="PowerShell 5.1+"></a>
  <a href="https://github.com/NousResearch/hermes-agent"><img src="https://img.shields.io/badge/Base-NousResearch%2Fhermes--agent-8A2BE2.svg" alt="Base: NousResearch/hermes-agent"></a>
</p>

---

## ✨ O que é

O **VORTEX AI** é um ambiente completo para rodar o [Hermes Agent](https://github.com/NousResearch/hermes-agent) — um agente de IA autônomo com **memória persistente**, **skills** que aprendem com a experiência, agendador de tarefas (**cron**), integração com plataformas de mensagens (Telegram, Discord, WhatsApp, Signal…) e orquestração de múltiplos agentes.

Este repositório já chega **pronto para uso**: um único comando de setup escaneia e instala todas as dependências, e os launchers incluídos dão acesso imediato ao **CLI**, **TUI**, **Gateway de mensagens** e ao **OpenCode** (via bridge MCP).

---

## 🧱 Estrutura do repositório

```
VORTEX_AI/
├─ hermes-agent/          # código-fonte do Hermes Agent (upstream, MIT)
│  ├─ skills/             # 16 categorias, 80+ skills (vortex, github, opencode...)
│  └─ opencode.jsonc      # config opencode upstream (usa ../bin/hermes.exe)
├─ .opencode/
│  └─ skills/vortex-hermes/ # BRIDGE VORTEX: opencode + Hermes (este repo)
├─ gateway-service/       # launchers do gateway (cmd/vbs)
├─ bin/                   # executáveis gerados pelo setup (não versionados)
├─ config.yaml            # configuração do agente (modelos, fallback, memória, segurança)
├─ opencode.jsonc         # CONFIG PRINCIPAL — Hermes MCP + ollama/lmstudio + skills
├─ setup.bat              # instalador 1-clique (duplo-clique) -> chama setup.ps1
├─ setup.ps1              # instalador / resolvedor de dependências (PowerShell)
├─ Iniciar.ps1            # launcher interativo (menu CLI / TUI / Gateway / OpenCode)
├─ Abrir-Hermes.bat       # inicia a CLI do Hermes
├─ Abrir-Hermes-TUI.bat   # inicia a interface TUI
├─ Abrir-OpenCode.bat     # inicia o OpenCode na raiz do projeto
├─ Abrir-OpenCode-Web.bat # inicia o OpenCode Web
├─ .env.example           # modelo de variáveis de ambiente
├─ SOUL.md                # persona / instruções do agente
└─ README.md
```

> 🔒 **Privacy-first:** segredos, sessões, memórias, bancos de dados e caches **não** são
> versionados (veja `.gitignore`). O que você clona é o software — não dados pessoais do autor.

---

## ✅ Pré-requisitos

- Windows 10/11 com **PowerShell 5.1+** (nativo) — ou WSL2/Linux
- Conexão com a internet na **primeira execução** (para baixar Python, `uv` e dependências)
- (Opcional, para OpenCode) **Node.js + npm**

---

## 🚀 Instalação (Windows) — *clone & use*

> **1 clique:** baixe do GitHub, duplo-clique em `setup.bat` e use. Sem `pip install` manual, sem dor de cabeça.

**Opção A — Duplo-clique (recomendado):**
```powershell
# 1) Clone
git clone https://github.com/luck-of-luck/VORTEX_AI.git
cd VORTEX_AI

# 2) Duplo-clique em setup.bat  (ou clique direito -> Executar)
#    Ele chama o setup.ps1, instala tudo e cria o .env automaticamente

# 3) Edite .env (o setup pergunta se quer abrir) e preencha PELO MENOS UMA:
#    CLINE_API_KEY (gratis: https://app.cline.bot) ou OPENROUTER_API_KEY
#    Alternativa 100% offline: instale Ollama (https://ollama.com) e pule chave

# 4) Pronto! Duplo-clique em Abrir-Hermes.bat
```

**Opção B — Terminal (mesmo resultado):**
```powershell
git clone https://github.com/luck-of-luck/VORTEX_AI.git
cd VORTEX_AI
powershell -ExecutionPolicy Bypass -File .\setup.ps1
# ou: .\setup.bat
notepad .env   # preencha 1 chave
.\Abrir-Hermes.bat
```

O `setup.bat` / `setup.ps1` faz tudo de forma **reprodutível** (usa o `uv.lock` do hermes-agent):

| Etapa | O que faz |
|-------|-----------|
| 1 | Valida / instala **Python 3.11–3.13** (winget ou instruções manuais) |
| 2 | Instala o gerenciador **uv** (Astral) |
| 3 | Sincroniza as dependências do `hermes-agent` (`uv sync`) |
| 4 | Gera os executáveis em `bin\` (hermes, hermes-acp, uv) |
| 5 | Cria `.env` a partir do `.env.example` + wizard de chaves (abre no bloco de notas se interativo) |
| 6 | Verifica **Node/npm + opencode** e **Ollama/LM Studio** (100% gratis/offline), oferece instalar |

> Extras opcionais: `setup.bat -Extras "messaging,mcp"` (padrão) ou `setup.ps1 -Extras "messaging,mcp"`.
> n8n: `setup.bat -WithN8nMCP` ou `setup.ps1 -WithN8nMCP`. Flags: `-SkipPythonCheck`, `-NonInteractive`, `-SkipNodeCheck`.

---

## 🖥️ Primeiros passos

```powershell
# CLI / chat direto
.\Abrir-Hermes.bat

# Interface TUI completa
.\Abrir-Hermes-TUI.bat

# Launcher interativo com menu
powershell -ExecutionPolicy Bypass -File .\Iniciar.ps1

# Direto pelo executável do venv
.\hermes-agent\venv\Scripts\hermes.exe
```

### OpenCode + Hermes — editor IA com skills e MCP (integrado)

> **VORTEX_AI já vem com `opencode.jsonc` configurado para usar Hermes como MCP + providers locais.**

```powershell
npm install -g opencode-ai   # se setup.bat não instalou
opencode                     # TUI (ou: Abrir-OpenCode.bat)
opencode mcp list            # deve mostrar: hermes ✓ connected
```

**O que já vem pronto em `opencode.jsonc` (raiz):**
- **MCP `hermes`** (`bin/hermes.exe mcp serve`) — 80+ skills Hermes dentro do opencode (gateway, cron, memory, browser, delegate...)
- **MCP `context7`** (desabilitado) — docs atualizadas de qualquer lib (`mcp invoke context7 ...`)
- **MCP `n8n`** (desabilitado) — após `hermes mcp install n8n` habilite em `opencode.jsonc`
- **Providers espelhados do `config.yaml`:** `cline` (minimax/deepseek), `openrouter` (`openrouter/free`, `z-ai/glm-5.2:free`), `ollama-local` (`qwen2.5-coder:32b`, `llama3.3:70b`), `lmstudio-local` (`:1234`)
- **References + Instructions:** `AGENTS.md` + `SOUL.md` + `hermes-agent/AGENTS.md` + catálogo `hermes-agent/skills` + bridge `.opencode/skills/vortex-hermes`

**Skill bridge `vortex-hermes`:** leia `.opencode/skills/vortex-hermes/SKILL.md` antes de codar no VORTEX via opencode. Ele ensina:
- quando usar Hermes via MCP (`hermes_*` tools) vs delegar para Hermes (`terminal: opencode run`)
- como carregar skills `vortex/*` e `github/*` dentro do opencode
- pitfalls (prompt caching, Windows home `%LOCALAPPDATA%\hermes`, reiniciar opencode após editar `opencode.jsonc`)

**Delegação cruzada:**
```bash
# Hermes → OpenCode (skill autonomous-ai-agents/opencode via Hermes)
opencode run "implemente X" -f file.ts

# OpenCode → Hermes (MCP hermes dentro do opencode)
# no prompt do opencode: "use hermes to run browser_navigate ..."
```

> Após editar `opencode.jsonc`, **reinicie o opencode** (config não hot-reload).

### Gateway (Telegram, Discord, WhatsApp, Signal…)

```powershell
.\hermes-agent\venv\Scripts\hermes.exe gateway setup
.\hermes-agent\venv\Scripts\hermes.exe gateway start
```

Ou use `gateway-service\Hermes_Gateway.cmd` (e o `.vbs` para iniciar oculto / desanexado).

---

## ⚡ Potência extra (já configurada)

### 🔍 Navegador automatizado
Nativo: `browser_navigate`, `browser_click`, `browser_type`, `browser_snapshot`, `browser_vision` (tira **screenshot e lê a tela com IA**), entre outros. Basta pedir ao Hermes algo como *"abra o site X e extraia Y"*. Usa o **Chrome/Edge local** automaticamente (ou providers cloud: Browser Use / Browserbase, via `.env`). Anexe a um navegador já aberto com `/browser connect`.

### 🔀 n8n (workflows e automação)
```powershell
# instala o bridge MCP oficial (catálogo Nous)
.\hermes-agent\venv\Scripts\hermes.exe mcp install n8n
# ou, no setup: powershell -File .\setup.ps1 -WithN8nMCP
```
Gere uma **API key** no n8n (**Settings → API**), preencha `N8N_BASE_URL` e `N8N_API_KEY` no `.env`, e o agente ganha ferramentas para listar, inspecionar, exportar e executar workflows n8n.

### 🧠 Esquema inteligente — visão de tela + contexto gigante
- **Modelo principal:** **MiniMax M2.5 via Cline** — "experimentação gratuita" (doc oficial da Cline), contexto de 1M e bom para leitura/edição de muitos arquivos.
- **Leitura de tela:** `auxiliary.vision` via **Cline** (`gpt-4o`, multimodal) — usado por `browser_vision`, `vision_analyze` e análise de imagens.
- **Contextos enormes:** limites de leitura elevados (`context_file_max_chars`/`file_read_max_chars` = 400k, saída de tools de até 150k) para o agente trabalhar com bases de código inteiras.

### ⚡ Muito mais agentes gratuitos (zero IAs pagas)
A cadeia de fallback (`config.yaml`) é **100% gratuita/barata** e troca automaticamente quando o principal falha (429/quota/429):

| Camada | Provedor | Modelos |
|--------|----------|---------|
| 🥇 Cline billing | `api.cline.bot` | `minimax/minimax-m2.5` (principal), `deepseek/deepseek-chat` |
| 🥈 ClinePass | `api.cline.bot` | `cline-pass/deepseek-v4-flash`, `cline-pass/qwen3.7-plus`, `cline-pass/glm-5.2` |
| 🥉 OpenRouter **`:free`** | openrouter.ai | `openrouter/free` (auto-router), `z-ai/glm-5.2:free`, Llama 3.3 70B, Qwen 2.5 72B |
| 🏠 Local (Ollama/LM Studio) | seu PC | `qwen2.5-coder:32b`, `llama3.3:70b` (offline, ilimitado) |

```bash
# 1) Crie sua chave gratuita/barata do Cline
#    app.cline.bot → Settings > API Keys → salve em .env:
CLINE_API_KEY=sk-...

# 2) Opcional — Ollama totalmente grátis e offline
ollama pull qwen2.5-coder:32b
ollama pull llama3.3:70b
```

> ℹ️ **ClinePass** é uma assinatura opcional de **US$ 9,99/mês** (2–5x o uso em modelos abertos) — sem ela, os modelos Cline ainda funcionam por uso/experimentação. Os **Cline Free Models** (tag "FREE") só funcionam no IDE/CLI da Cline, não via API.

## 🔌 Integração com todas as IAs do seu PC

O `config.yaml` já integra os **provedores** e os **CLIs** das IAs instaladas
(skill **`ai-app-orchestration`**). Cadeia de fallback automática:

| Ordem | IA | Como ativa |
|------|-----|-----------|
| 1-5 | **Cline** (minimax/deepseek/ClinePass) | `CLINE_API_KEY` |
| 6 | **GitHub Copilot** (gpt-4.1) | `COPILOT_GITHUB_TOKEN`/`GH_TOKEN` |
| 7 | **Claude / Anthropic** | `ANTHROPIC_API_KEY` |
| 8 | **Kimi / Moonshot** | `KIMI_API_KEY` |
| 9-13 | OpenRouter `:free` | `OPENROUTER_API_KEY` (ou `openrouter/free` auto) |
| 14 | **LM Studio** (local) | abra o app → Developer → Start Server (`:1234`) |
| 15-18 | **Ollama** (local, offline) | `ollama serve` + `ollama pull qwen2.5-coder:32b` |

**Delegar tarefas a outros agentes** (Claude Code, Cursor, Qoder, Zed, Kimi,
OpenCode) via terminal — headless, um por vez:

```bash
claude -p "implemente X"        # Claude Code headless
cursor run "implemente X"       # Cursor
qoder run "implemente X"        # Qoder
kimi -p "implemente X"          # Kimi
opencode run "implemente X"     # OpenCode
zed --agent -p "implemente X"   # Zed (experimental)
```

Apps sem CLI (**Replit**, **IBM Bob**, **Antigravity**, **ChatGPT**) são
usados pelo **protocolo visual** (navegador como usuário).

---

### ✅ Commits automáticos no branch (agora globais / multi-repo)
Regra persistente no `SOUL.md` + skill **`git-commit-workflow`**: como você **sempre fala o repositório no início**, o agente trabalha **dentro desse repositório** e, ao **final de cada tarefa**, faz `git add` + `git commit` **no branch atual dele** (padrão conventional commits; **nunca** `push --force`). Push remoto só quando você pedir.

### 🔭 Protocolo Visual-Cognitivo (navegar como usuário que está vendo pela 1ª vez)
Skill **`visual-browser-user-protocol`** + documento em [`PROTOCOLOS/visual-user-browser.md`](PROTOCOLOS/visual-user-browser.md).

O agente **não assume que conhece a interface**: ele **enxerga a tela** com uma IA de visão (`browser_vision annotate`, refs `@eN`), age em passos pequenos, **verifica visualmente** o resultado e **aprende incrementalmente** — salvando um *learning journal* persistente em `HERMES_HOME/protocol/browser-learning/` que é consultado na próxima sessão.

```
OBSERVAR → INTERPRETAR → AGIR → VERIFICAR → REGISTRAR
```
Basta pedir: *"use o protocolo visual e explore o sistema X"*.

---

## ⚙️ Configuração

| Arquivo | Finalidade |
|---------|-----------|
| `.env` | Chaves de API e variáveis de ambiente (nunca versionado) |
| `config.yaml` | Modelos + fallback, memória, segurança, cron, kanban, delegação |
| `opencode.jsonc` | Ponte MCP Hermes ↔ OpenCode |
| `SOUL.md` | Persona e instruções do agente |

Troque de modelo a qualquer momento com `/model` no chat, ou edite `config.yaml`.

---

## 🧭 Comandos úteis

| Comando | Ação |
|---------|------|
| `hermes` | Inicia o chat (CLI) |
| `hermes --tui` | Interface TUI |
| `hermes gateway setup` / `gateway start` | Configura / inicia o gateway de mensagens |
| `hermes mcp serve` | Servidor MCP (usado pelo OpenCode) |
| `hermes cron list` | Lista tarefas agendadas |
| `hermes model` | Troca de modelo / provedor |
| `hermes skills list` | Lista habilidades instaladas |
| `hermes memory status` | Estado da memória |

---

## 🔐 Privacidade & segurança

- `.gitignore` robusto: `.env`, `auth.json`, sessões, memórias, `state.db`, caches e `bin\` **nunca** entram no Git.
- O agente roda **localmente** — você controla suas chaves e dados.
- Por padrão, o Hermes exige **aprovação** para comandos destrutivos (`config.yaml → approvals`).
- Para tarefas não supervisionadas, rode em **VM / sandbox / Docker** (veja o `Dockerfile` do hermes-agent).

---

## 🛟 Solução de problemas

- **Antivírus acusa `uv.exe`:** falso positivo conhecido (binário Rust da Astral). Exclua a pasta `bin\` do AV ou valide via attestation (veja README do hermes-agent).
- **`hermes` não é reconhecido:** rode o `setup.bat` (ou `setup.ps1`) novamente ou use `hermes-agent\venv\Scripts\hermes.exe`.
- **`setup.bat` não abre / pisca e fecha:** clique direito → **Executar com PowerShell** ou rode `powershell -ExecutionPolicy Bypass -File setup.ps1` no terminal dentro da pasta.
- **Python não encontrado:** instale em https://www.python.org/downloads/ (marque **Add to PATH**) e rode `setup.bat` de novo. Ou: `winget install Python.Python.3.12`.
- **Gateway não inicia:** confira as chaves da plataforma no `.env` e os logs em `logs\`.
- **Sem chave API?** Use **Ollama 100% offline**: https://ollama.com → `ollama pull qwen2.5-coder:32b` → `ollama serve` → já funciona sem chave.

---

## 📜 Licença & créditos

- Código deste repositório: **MIT** © 2026 VORTEX_AI Contributors ([LICENSE](LICENSE)).
- `hermes-agent/`: **MIT** © Nous Research — veja [`hermes-agent/LICENSE`](hermes-agent/LICENSE) e o [repositório oficial](https://github.com/NousResearch/hermes-agent).
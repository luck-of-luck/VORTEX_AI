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
├─ gateway-service/       # launchers do gateway (cmd/vbs)
├─ bin/                   # executáveis gerados pelo setup.ps1 (não versionados)
├─ config.yaml            # configuração do agente (modelos, fallback, memória, segurança)
├─ opencode.jsonc         # bridge MCP Hermes ↔ OpenCode
├─ setup.ps1              # instalador / resolvedor de dependências (1 comando)
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

## 🚀 Instalação (Windows)

```powershell
# 1) Clone
git clone https://github.com/luck-of-luck/VORTEX_AI.git
cd VORTEX_AI

# 2) Setup: instala/escanéia todas as dependências automaticamente
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# 3) Configure suas chaves de API
#    O setup cria o .env automaticamente. Edite-o e preencha pelo menos uma
#    chave (recomendado: OPENROUTER_API_KEY).

# 4) Pronto! Inicie
.\.Abrir-Hermes.bat
```

O `setup.ps1` faz tudo de forma **reprodutível** (usa o `uv.lock` do hermes-agent):

| Etapa | O que faz |
|-------|-----------|
| 1 | Valida / instala **Python 3.11–3.13** (winget) |
| 2 | Instala o gerenciador **uv** (Astral) |
| 3 | Sincroniza as dependências do `hermes-agent` |
| 4 | Gera os executáveis em `bin\` (hermes, hermes-acp) |
| 5 | Cria `.env` a partir do `.env.example` |

> Extras opcionais (mensageria, MCP, etc.): `setup.ps1 -Extras "messaging,mcp"` (padrão).
> Instala também o bridge do **n8n** com `-WithN8nMCP`. Suporta `-SkipPythonCheck`.

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

### OpenCode (opcional)

```powershell
npm install -g opencode-ai
opencode
```

O `opencode.jsonc` já conecta o **MCP `hermes`** (`bin\hermes.exe mcp serve`) automaticamente.

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
A cadeia de fallback (`config.yaml`) é **100% gratuita/barata** e troca automaticamente quando o principal falha:

| Camada | Provedor | Modelos |
|--------|----------|---------|
| 🥇 Cline billing | `api.cline.bot` | `minimax/minimax-m2.5` (principal), `deepseek/deepseek-chat` |
| 🥈 ClinePass | `api.cline.bot` | `cline-pass/deepseek-v4-flash`, `cline-pass/qwen3.7-plus`, `cline-pass/glm-5.2` |
| 🥉 OpenRouter **`:free`** | openrouter.ai | Llama 3.3 70B, Qwen 2.5 72B, Nemotron |
| 🏠 Local (Ollama) | seu PC | `qwen2.5-coder:32b`, `llama3.3:70b` (offline, ilimitado) |

```bash
# 1) Crie sua chave gratuita/barata do Cline
#    app.cline.bot → Settings > API Keys → salve em .env:
CLINE_API_KEY=sk-...

# 2) Opcional — Ollama totalmente grátis e offline
ollama pull qwen2.5-coder:32b
ollama pull llama3.3:70b
```

> ℹ️ **ClinePass** é uma assinatura opcional de **US$ 9,99/mês** (2–5x o uso em modelos abertos) — sem ela, os modelos Cline ainda funcionam por uso/experimentação. Os **Cline Free Models** (tag "FREE") só funcionam no IDE/CLI da Cline, não via API.

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
- **`hermes` não é reconhecido:** rode o `setup.ps1` novamente ou use `hermes-agent\venv\Scripts\hermes.exe`.
- **Gateway não inicia:** confira as chaves da plataforma no `.env` e os logs em `logs\`.

---

## 📜 Licença & créditos

- Código deste repositório: **MIT** © 2026 VORTEX_AI Contributors ([LICENSE](LICENSE)).
- `hermes-agent/`: **MIT** © Nous Research — veja [`hermes-agent/LICENSE`](hermes-agent/LICENSE) e o [repositório oficial](https://github.com/NousResearch/hermes-agent).
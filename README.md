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
> Também suporta `-SkipPythonCheck`.

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
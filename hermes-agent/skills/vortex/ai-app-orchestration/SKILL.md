---
name: ai-app-orchestration
description: "Orchestrate every AI on the PC: delegate tasks to Claude Code, Cursor, Qoder, Zed, Kimi, OpenCode CLIs via terminal, and route model fallback across Copilot/Anthropic/Kimi/LM Studio/Ollama."
version: 1.0.0
author: VORTEX_AI
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [orchestration, claude, cursor, qoder, zed, kimi, opencode, copilot, ollama, lmstudio, delegation]
    related_skills: [visual-browser-user-protocol, git-commit-workflow, opencode]
---

# AI App Orchestration — usar todas as IAs do PC

Este agente coordena **todas as IAs instaladas no PC**. Duas formas de uso:

1. **Provedores de modelo** (config.yaml): quando o modelo principal falhar, a
   cadeia de fallback tenta Copilot → Claude → Kimi → LM Studio → Ollama
   automaticamente.
2. **CLIs agênticos externos**: delegar uma tarefa inteira a outro agente
   (via `terminal`/`delegate_task`), cada um com seu próprio fluxo.

## Mapa de IAs do PC

| App | Caminho (típico) | Tipo de integração |
|-----|------------------|--------------------|
| **Claude Code** | `claude` (no PATH) | CLI agêntico + provider `anthropic` |
| **GitHub Copilot** | conta GitHub (`gh`/token) | provider `copilot` |
| **OpenCode** | `opencode` (npm) | CLI agêntico + bridge MCP (ver skill `opencode`) |
| **Cursor** | `cursor` (`...\cursor\resources\app\bin\cursor.cmd`) | CLI agêntico |
| **Qoder** | `qoder` (`C:\Program Files\Qoder\bin\qoder.cmd`) | CLI agêntico |
| **Kimi** | `kimi` (`...\.kimi-code\bin\kimi.exe`) | CLI agêntico + provider `kimi-coding` |
| **Zed** | `zed` (`...\Zed\bin\Zed.exe`) | CLI agêntico |
| **Ollama** | `ollama` | servidor local + provider `ollama-local` |
| **LM Studio** | app desktop | servidor `:1234` + provider `lmstudio-local` |
| **ChatGPT / Codex** | navegador / `hermes auth` | OAuth `openai-codex` |
| **Replit** | PWA (web) | navegador (protocolo visual) |
| **IBM Bob** | app desktop | navegador/app (sem CLI) |
| **Antigravity** | app desktop | web/app (sem CLI) |

## 1) Provedores na queda de modelo (comportamento automático)

Já configurado em `config.yaml`: quando o principal falha (429/exausto), a
cadeia tenta, em ordem:

```
cline → cline-pass → copilot (gpt-4.1) → anthropic (claude-sonnet-4-6)
→ kimi-coding (kimi-k2) → openrouter :free → lmstudio-local → ollama-local
```

Cada um exige a chave de API correspondente no `.env`:
`CLINE_API_KEY`, `COPILOT_GITHUB_TOKEN`/`GH_TOKEN`, `ANTHROPIC_API_KEY`,
`KIMI_API_KEY`. Para locais, os servidores precisam estar **rodando**:
Ollama (`ollama serve`/app) e LM Studio (aba Developer → Start Server).
Entradas sem credencial/serviço são puladas automaticamente.

## 2) Delegar tarefa para outro agente (CLI)

Use `terminal` (ou `delegate_task`) para chamar outros agentes. **Sempre**
rode `--help` primeiro se não tiver certeza do subcomando.

### Claude Code
```bash
claude -p "tarefa" --output-format text        # headless (não interativo)
claude                                          # abre sessão interativa (evitar)
```
- Requer login: `claude` (primeira execução faz OAuth).
- Ótimo para refactoring pesado de código.

### Cursor
```bash
cursor run "tarefa"   # (ou: cursor --prompt "tarefa") — confira com cursor --help
```
- Funciona sobre o workspace do Cursor; abra o projeto correto antes.

### Qoder (fork do Cline)
```bash
qoder run "tarefa"    # confira com qoder --help
```
- Alternativa com suporte a vários providers.

### Kimi CLI
```bash
kimi -p "tarefa"      # modo headless (padrão estilo claude -p)
```
- Requer config da conta da Kimi. Alternativa com contexto grande.

### Zed (modo agente)
```bash
zed --agent -p "tarefa"   # experimental — confira zed --help
```
- Zed terminal; alternativas: `zed -m Agent` ou `zed call`.

### OpenCode (ver skill `opencode` para detalhes)
```bash
opencode run "tarefa"
```

### Ollama (modelos locais)
```bash
ollama pull qwen2.5-coder:32b   # baixa se ainda não tiver
ollama run qwen2.5-coder:32b "pergunta"
```

## 3) IAs sem CLI (Replit, IBM Bob, Antigravity, ChatGPT)

Use o **protocolo visual** (skill `visual-browser-user-protocol`) para
"usar a interface como um usuário": abra o site/app, veja a tela com visão,
clique, digite e aprenda o fluxo. Exemplos:
- Replit → `https://replit.com`
- ChatGPT → `https://chatgpt.com`
- Antigravity → site/app da Antigravity
- IBM Bob → app desktop (via assistente visual se abrir em janela)

## Regras

- **Nunca** deixe um CLI agêntico "completar" sem conferir o resultado —
  sempre `git status` no repositório alvo depois (skill `git-commit-workflow`).
- Não misture agentes no mesmo repositório sem necessidade; prefira delegar a
  tarefa inteira a um só agente para evitar conflitos de edição.
- CLIs interativos (`claude`/`cursor` sem `-p`) **não** devem ser usados em
  automação (travam o terminal).
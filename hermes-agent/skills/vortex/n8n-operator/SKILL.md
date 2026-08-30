---
name: n8n-operator
description: "Integrate Hermes with n8n: install/use the MCP bridge, manage workflows, executions, and export/import automations."
version: 1.0.0
author: VORTEX_AI
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [n8n, automation, workflows, mcp, api]
    related_skills: [git-commit-workflow]
---

# n8n Operator

Integra o Hermes com instâncias [n8n](https://n8n.io) (automação visual de workflows) de duas formas: **MCP bridge** (ferramentas nativas) ou **API REST** (via terminal).

## 1) Instalar o MCP bridge (recomendado)

```bash
hermes mcp install n8n
```

- Faz `git clone` em `${HERMES_HOME}/mcp-installs/n8n` e cria o venv.
- Pede a URL (`http://127.0.0.1:5678` por padrão) e a API key (gerada em **Settings → API**).
- Escreve a entrada `mcp_servers.n8n` no `config.yaml` automaticamente.
- Ferramentas: `health`, `list_workflows`, `get_workflow`, `find_workflows`, `list_executions`, `get_execution`, `recent_failures`, `export_workflow`.
- Reinicie a sessão (ou `/reload-mcp`) para carregar as tools.

Credenciais vivem no `.env`: `N8N_BASE_URL`, `N8N_API_KEY`.

## 2) Fallback: API REST do n8n (sem MCP)

A API local usa `X-N8N-API-KEY`:

```bash
# Listar workflows (v1)
curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_BASE_URL/api/v1/workflows"
# Detalhar um workflow
curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_BASE_URL/api/v1/workflows/<id>"
# Execuções
curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_BASE_URL/api/v1/executions"
```

- `GET  /api/v1/workflows` — listar
- `GET  /api/v1/workflows/{id}` — detalhar
- `POST /api/v1/workflows` — criar
- `PUT  /api/v1/workflows/{id}` — atualizar
- `GET  /api/v1/executions` — histórico de execuções

## 3) Boas práticas

- Faça `export_workflow` antes de qualquer mutação de um workflow ativo.
- Ativar/desativar workflows é **mutação real** no n8n — confirme com o usuário antes.
- Quando exportar workflows (JSON) como parte de uma tarefa, **commite no repositório** (veja `git-commit-workflow`).
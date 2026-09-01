# PROTON — JARVIS | VORTEX_AI

> **Seu JARVIS particular.** Interface RTX com raytracing, fluidez 60FPS, estética futurista neon quente sobre grafite metálico, conectada ao **Hermes Agent** via MCP.

![PROTON](https://img.shields.io/badge/PROTON-JARVIS-FF6B35?style=for-the-badge) ![RTX](https://img.shields.io/badge/RTX-ON-00F5FF?style=flat-square) ![FLUID](https://img.shields.io/badge/FLUID-60FPS-FF006E?style=flat-square)

## O que é

**PROTON** é um app independente (web) para usar o **Hermes Agent** como um **JARVIS**:

- **RTX raytracing** — esfera metálica com `MeshPhysicalMaterial` (clearcoat, transmissão, envMap CubeCamera), 3 luzes pontuais (laranja/magenta/cyan) + reflexos em tempo real a 60FPS (Three.js)
- **Fluidez** — canvas com 140 partículas + conexões, atração ao mouse, 60FPS
- **Estética** — fundo grafite metálico (`#0A0A0B` → `#1A1A1E` → `#2A2A2E`) com glows radiais neon quente (`#FF6B35`/`#FF006E`/`#00F5FF`/`#FFB000`), glassmorphism, grid perspectiva, scanlines, noise, vignette
- **HUD JARVIS** — orbe central pulsante, VU meter, painéis SYSTEM/HERMES/SENSORES, dock CONTROLS, chat glassmorphism com neon

## Como abrir

```powershell
# Opção 1: duplo-clique (recomendado)
Abrir-PROTON.bat
# ou
start proton\index.html

# Opção 2: via Iniciar.ps1
powershell -File Iniciar.ps1  # escolha 9) PROTON

# Opção 3: servidor local (evita file:// CORS se precisar)
npx serve proton
# ou
python -m http.server 8080 --directory proton
```

> **Após editar `opencode.jsonc`, reinicie o opencode.** Windows home: `%LOCALAPPDATA%\hermes`.

## Conexão com Hermes

PROTON tenta se conectar ao **Hermes Gateway** em `http://127.0.0.1:3010/api/gateway/status` (se você rodar `hermes gateway run` ou `hermes --tui`). Se não estiver rodando, cai em **mock inteligente** (respostas simuladas com as skills certas).

**MCP (para o opencode):** `opencode.jsonc` já tem:
```json
"mcp": {
  "hermes": { "command": ["bin/hermes.exe","mcp","serve"], "enabled": true },
  "context7": { "url": "https://mcp.context7.com/mcp", "enabled": false },
  "n8n": { "command": ["hermes-agent/venv/Scripts/python.exe","../mcp-installs/n8n/server.py"], "enabled": false }
}
```
Verifique: `opencode mcp list` → `hermes ✓ connected`.  
Skill bridge: `.opencode/skills/vortex-hermes/SKILL.md` ensina o opencode a usar Hermes via MCP e delegar via `opencode run`.

## Atalhos

- **Enter** enviar, **Shift+Enter** quebra linha
- **Ctrl+K** limpar chat, **Ctrl+M** microfone
- Clique no **orbe** para falar (Web Speech API, Chrome/Edge)
- Chips: `Explique o VORTEX_AI` / `Ative o browser` / `Crie um skill` / `/imagine`

## Voz

- Clique no orbe ou no botão 🎙️. Requer **Chrome/Edge** com permissão de microfone.
- Duplo-clique no orbe alterna **voz sintética** (speechSynthesis).

## Arquivos

```
proton/
├─ index.html   # app completo (Tailwind CDN + Three.js + fluid canvas + chat)
├─ README.md    # este arquivo
```

`index.html` é **single-file** (sem build) — duplo-clique funciona offline após primeiro cache de CDNs (Tailwind, Three.js, Google Fonts). Para 100% offline, baixe os CDNs ou use `npm`.

## Tecnologias

- **Tailwind CDN** + **Three.js 0.160** (ESM via importmap) + **Canvas 2D** (fluid)
- **Geist Mono** + **Syne** + **Instrument Sans** + **Rajdhani** (Google Fonts)
- **Web Speech API** (STT/TTS)
- Sem dependências de build — funciona como app independente

## Roadmap

- [ ] Conectar PROTON diretamente ao `bin/hermes.exe` via `fetch` para `hermes gateway` WebSocket
- [ ] Adicionar **opencode web** (`opencode web` → `http://localhost:4096`) como iframe
- [ ] Empacotar como **Electron** (`proton/electron`) para app desktop com tray
- [ ] **Voz 24/7** com `wake` (Hey PROTON) via `openWakeWord`

---

**VORTEX_AI** • PROTON v1.0 • RTX ON • Grafite metálico • Neon quente • 60FPS

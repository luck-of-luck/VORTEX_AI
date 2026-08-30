# 🔭 Protocolo Visual-Cognitivo — Navegador como Usuário Humano

> **Versão:** 1.0 · **Aplicável em:** Hermes Agent (VORTEX_AI) · **Skill:** `visual-browser-user-protocol`

Este protocolo transforma a interação do agente com interfaces web em uma
**experiência de "primeiro acesso"**: a IA **vê a tela** com um modelo de visão,
age em pequenos passos como um humano, **confere o resultado**, e **aprende
incrementalmente** — registrando em memória persistente tudo o que descobriu
sobre o sistema.

Nada de adivinhar: o conhecimento é **construído pela experiência**, não
injetado.

---

## 1. Por que existe

IAs normalmente "acham que sabem" como uma interface funciona. Este protocolo
inverte isso:

| Atitude humana | Atitude do protocolo |
|---|---|
| "Deixa eu ver a tela" | `browser_vision(annotate=true)` antes de qualquer ação |
| "Um passo de cada vez" | 1 ação → 1 verificação visual |
| "Ah, então é aqui que fica" | journal de aprendizado persistente |
| "Não era isso, vou voltar" | recuo após 2 falhas, nunca insistência cega |

---

## 2. Ciclo

```
OBSERVAR → INTERPRETAR → AGIR → VERIFICAR → REGISTRAR
   ↑                                              │
   └────────────── (próximo ciclo) ───────────────┘
```

### OBSERVAR
- `browser_navigate(url)` para abrir, ou usar a aba atual.
- `browser_vision(question="Descreva a página: layout, blocos, textos,
  botões, campos, estado (vazio/erro/logado)", annotate=true)`.
  - `annotate=true` desenha **labels numerados [N]** nos elementos
    interativos → cada `[N]` vira o ref `@eN` para cliques/digitação.
- Reforço textual quando útil: `browser_snapshot` (árvore de acessibilidade).

### INTERPRETAR
- Entenda a hierarquia visual: o que é principal, menu, formulário, estado.
- Se ambiguidade: nova pergunta focada de `browser_vision` no elemento —
  melhor que chutar.
- Consulte o **journal** do sistema antes de agir.

### AGIR
- Uma ação por vez: `browser_click("@e12")`, `browser_type("@e7", "texto")`,
  `browser_press("Enter")`, `browser_scroll("down")`.
- **Somente refs vistos na última observação.** Nunca inventar.

### VERIFICAR
- `browser_vision(question="O que mudou? Erros, toasts, novas seções,
  popups, loading?")`.
- Se quebrou: `browser_console` para ver JS errors.
- Confirme o efeito antes de avançar.

### REGISTRAR
- Diário persistente em:
  `HERMES_HOME/protocol/browser-learning/<host>-<pasta>.md`
- Estrutura do journal (criar/atualizar, nunca apagar o que já se sabe):

```markdown
# Aprendizado: exemplo.com
## Mapa visual
- Header: logo + menu [Perfil] [Config] [+ Novo]
- Formulário: campo email (@e3), campo senha (@e5), botão [Entrar] (@e7)
## Fluxos descobertos
- "Novo projeto": [Novo] → formulário → Salvar → projeto
## Armadilhas
- Login falho → toast vermelho no topo (sem aviso no campo)
- Relatório demora ~3s; aguardar antes de clicar
## O que NÃO funciona
- [x] [Exportar] não existe na tela inicial (só dentro do projeto)
```

---

## 3. Ferramentas (Hermes)

| Tool | Papel |
|------|-------|
| `browser_navigate` | Abrir/ir para a URL |
| `browser_vision(annotate=true)` | **O "olho"**: screenshot + análise visual + refs |
| `browser_snapshot` | Mapa textual (reforço de acessibilidade) |
| `browser_click/@eN` | Clicar no que viu |
| `browser_type/@eN` | Digitar no campo que viu |
| `browser_press` | Enter/Tab/Escape (formulários, navegação) |
| `browser_scroll` | Rolar como humano |
| `browser_console` | Diagnóstico quando algo falha |

**Modelo de visão:** usa `auxiliary.vision` — se o modelo principal não vê
imagens, o Hermes envia o screenshot à IA de visão e devolve análise textual.

---

## 4. Regras anti-alucinação

1. **Se não viu, não age.** Re-observar primeiro.
2. **Refs vêm da última observação.** Navegou/recarregou? Re-`browser_vision`.
3. **Não fingir sucesso.** Verificação não confirmou? Reporte o estado real.
4. **Popups de consentimento** (cookies, "aceitar") são parte do fluxo humano — trate-os.
5. **Loading** → aguarde e re-observe; nunca clique às cegas.
6. **2 falhas = recuo.** Voltar/recarregar e re-explorar.

---

## 5. Ativação

O protocolo é disparado quando o usuário pede para **"usar o navegador como um
usuário"**, **"ver a tela"**, **"explorar/descobrir a interface"**, ou em
tarefas de **teste manual / QA guiado por visão**.

```text
usuário: "Use o protocolo visual. Explore o sistema X e aprenda como funciona."
agente:  aplica o ciclo até concluir e deixa o journal em
         HERMES_HOME/protocol/browser-learning/
```

---

Veja também: [hermes-agent/website/docs/user-guide/features/browser.md](hermes-agent/website/docs/user-guide/features/browser.md).
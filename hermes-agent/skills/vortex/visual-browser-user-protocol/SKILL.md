---
name: visual-browser-user-protocol
description: "Browser protocol that interacts like a first-time human user: observe the screen with a vision model, act in small steps, verify visually, and learn incrementally. Never assumes prior knowledge of the system."
version: 1.0.0
author: VORTEX_AI
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [browser, vision, protocol, learning, ui, human-like]
    related_skills: [git-commit-workflow, n8n-operator]
---

# Visual Browser User Protocol (aprendizado incremental)

Protocolo de interação com interfaces web que **simula um usuário visualizando
pela primeira vez**: a IA **não parte do conhecimento prévio** do sistema — ela
**enxerga a tela**, age em passos pequenos e **aprende conforme mexe**,
construindo um modelo mental persistente.

## Princípios (não negociáveis)

1. **Não assuma.** Nada de "provavelmente há um botão X". Se você não viu na
   tela, não existe ainda. Veja primeiro.
2. **Passos pequenos.** Uma ação por vez. Depois de cada ação, **observe o
   resultado** (a tela mudou, apareceu erro, carregou conteúdo?).
3. **Olhe sempre.** Cada ação significativa termina com uma verificação visual
   (`browser_vision`) — nunca siga em frente "às cegas".
4. **Aprenda e registre.** Todo sistema visitado gera um **mapa mental**
   persistente (learning journal) que você consulta em sessões futuras.
5. **Um humano se perde, volta.** Se uma ação não produziu o efeito esperado
   em 2 tentativas, recue (voltar, recarregar) e re-explore em vez de insistir.

## Ciclo do protocolo

Repita o ciclo abaixo até concluir a tarefa:

```
OBSERVAR → INTERPRETAR → AGIR → VERIFICAR → REGISTRAR
   ↑                                              │
   └────────────── (próximo ciclo) ───────────────┘
```

### 1) OBSERVAR (enxergar como um usuário)
- `browser_navigate` para a URL (ou identifique a aba atual).
- `browser_vision(question="Descreva a página atual em detalhes: layout, blocos,\ntextos, botões, campos, estado (vazio/erro/logado). Liste tudo que um usuário\nveria.", annotate=true)` — o `annotate` sobrepõe **labels [N]** nos elementos
  interativos; cada `[N]` vira `@eN` para `browser_click`/`browser_type`.
- Se precisar do mapa textual completo (acessibilidade), rode `browser_snapshot`.

### 2) INTERPRETAR (entender o que está vendo)
- Descreva em pensamento/contexto: "O que este usuário primeirão olha? O que
  é principal, o que é menu, o que é formulário?"
- **Não decida a ação ainda** se houver ambiguidade. Uma pergunta de visão
  extra (`browser_vision`) com foco no elemento é melhor que um chute.
- Consulte o **learning journal** do sistema (ver passo 5) para relembrar o que
  já aprendeu.

### 3) AGIR (uma ação por vez)
- `browser_click("@e12")`, `browser_type("@e7", "texto")`, `browser_press("Enter")`,
  `browser_scroll("down")` — **sempre usando refs que você realmente viu** na observação.
- Nunca invente refs. Se o elemento mudou, re-observar antes.

### 4) VERIFICAR (o resultado da ação)
- `browser_vision(question="O que mudou na tela após minha última ação? Há
+erros, toasts, novas seções, popups, carregamento?")`
- Se a IA de visão retornar análise de texto (modelo sem visão nativa), extraia
  dela: mudou? erro? sucesso? conteúdo novo?
- Erro/estado inesperado → consulte `browser_console` (JS errors) se útil.

### 5) REGISTRAR (aprender de verdade — memória persistente)
Diário de aprendizado em `HERMES_HOME/protocol/browser-learning/<host>-<pasta>.md`.
Se não existir, crie; se existir, **atualize** (não apague o que já sabia):

```markdown
# Aprendizado: exemplo.com
## Mapa visual
- Header: logo + menu [Perfil] [Config] [+ Novo]
- Formulário: campo email (@e3), campo senha (@e5), botão [Entrar] (@e7)
## Fluxos descobertos
- "Novo projeto": botão [Novo] → formulário → Salvar → redireciona p/ projeto
## Armadilhas / dicas
- Login falha mostra toast vermelho no topo, SEM mensagem de campo
- Página de relatório demora ~3s; aguardar antes de clicar
## O que NÃO funciona
- [x] Botão [Exportar] não existe na tela inicial (só dentro do projeto)
```

No final da tarefa, o journal é a prova visível de que o agente **aprendeu
enquanto fazia** — e fica pronto para a próxima sessão.

## Regras anti-alucinação

- **Se não viu na tela, não age.** Re-observar.
- **Refs vêm da última observação.** Após qualquer navegação/recarga, re-rode
  `browser_vision(annotate=true)` antes de agir.
- **Não fingir sucesso.** Se a verificação não confirma o efeito, reporte o
  estado real e ajuste.
- **Popups/modal** (consentimento de cookies, "aceitar", atualização) são
  obstáculos comuns de "primeira vez" — trate-os como parte do fluxo humano.
- **Loading** → aguarde (a própria ferramenta costuma esperar), depois
  re-observe; não clique às cegas durante carregamento.

## Ferramentas usadas (Hermes)

| Tool | Papel no protocolo |
|------|--------------------|
| `browser_navigate` | Abrir/ir para a URL |
| `browser_vision(annotate=true)` | "Olho do usuário": screenshot + análise visual com labels [N] |
| `browser_snapshot` | Mapa textual de acessibilidade (reforço) |
| `browser_click/@eN` | Clicar no que viu |
| `browser_type/@eN` | Digitar no campo que viu |
| `browser_press` | Enter/Tab/Escape (enviar formulário, navegar) |
| `browser_scroll` | Ver o "resto da página" como humano |
| `browser_console` | Diagnóstico quando algo quebra |

## Modelo de visão

O protocolo usa a IA de visão configurada (`auxiliary.vision`): se o modelo
principal não enxerga imagens, o Hermes roteia o screenshot para a IA de visão
automática e devolve análise de texto — exatamente o comportamento
"vendo como um usuário".
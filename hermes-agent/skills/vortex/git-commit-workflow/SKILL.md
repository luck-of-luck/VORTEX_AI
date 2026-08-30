---
name: git-commit-workflow
description: "Global workflow: at the end of every task, commit changes on the current branch of the repository the user named at the start. Works across any repo."
version: 2.0.0
author: VORTEX_AI
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [git, commit, workflow, version-control, multi-repo]
    related_skills: [github-git-bridge]
---

# Git Commit Workflow (global / multi-repo)

Regra permanente deste agente: **toda tarefa termina com um commit**, sempre **no repositório em que o usuário está trabalhando**. O usuário costuma **falar o repositório/projeto no início da conversa** — esse é o alvo da tarefa.

## 0) Definir o repositório de trabalho

- Se o usuário **nomeou um repositório/projeto no início**, use-o:
  - Se o caminho foi dado, trabalhe dentro dele (`cd <caminho>` / terminal com `workdir`).
  - Se só o nome/remoto foi dado, localize um clone existente (pergunte se não achar).
- Se **não nomeou nenhum**, use o diretório atual se for um repo git; caso contrário, apenas descreva as mudanças sem commitar.

## 1) Procedimento ao final de cada tarefa

1. Confirme que está dentro do repositório: `git rev-parse --show-toplevel`.
2. `git branch --show-current` — **nunca mude de branch por conta própria**; commite no branch atual. Só crie branch se o usuário pedir explicitamente.
3. `git status --short` — revise o que mudou (staged, unstaged, untracked).
4. `git add -A` — inclua as mudanças (ou adicione seletivamente quando fizer sentido).
5. `git commit -m "<tipo>: <resumo>"` com prefixos convencionais:
   - `feat:` nova funcionalidade · `fix:` correção · `docs:` documentação
   - `chore:` manutenção/config · `refactor:` reestruturação · `perf:` performance · `build:` scripts
6. **Nunca** `git push --force` / `git push -f`. Push remoto apenas se o usuário pedir.

## Detalhes

- Mensagens curtas, descritivas, em pt-BR ou inglês.
- Em repositórios com CI, se o usuário pedir push, espere a suíte validar antes de considerar concluído.
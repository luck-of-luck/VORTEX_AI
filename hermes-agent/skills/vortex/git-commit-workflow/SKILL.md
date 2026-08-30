---
name: git-commit-workflow
description: "Finalize every task by committing changes on the current git branch with a clean conventional-commit message."
version: 1.0.0
author: VORTEX_AI
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [git, commit, workflow, version-control]
    related_skills: [github-git-bridge]
---

# Git Commit Workflow (finalizar tarefa)

Regra permanente deste agente: **toda tarefa termina com um commit no branch atual** (salvo instrução contrária do usuário).

## Procedimento ao final de cada tarefa

1. `git branch --show-current` — confirme o branch atual; nunca mude de branch sem o usuário pedir.
2. `git status --short` — revise o que mudou (staged, unstaged, untracked).
3. `git add -A` — inclua as mudanças (ou adicione seletivamente quando fizer sentido).
4. `git commit -m "<tipo>: <resumo>"` com prefixos convencionais:
   - `feat:` nova funcionalidade
   - `fix:` correção de bug
   - `docs:` documentação / README
   - `chore:` manutenção / config
   - `refactor:` reestruturação sem mudar comportamento
   - `perf:` otimização de performance
   - `build:` scripts de build / setup
5. Se restarem arquivos não rastreados relevantes (ex.: nova configuração), inclua-os e commite.
6. **Nunca** `git push --force` / `git push -f`. Push remoto apenas se o usuário pedir explicitamente.

## Detalhes

- Mensagens curtas, descritivas, em pt-BR ou inglês.
- Se o commit falhar por identidade git (user.name/email ausentes), informe o usuário com o comando necessário.
- Em repositórios com CI, espere a suíte validar antes de considerar a tarefa concluída quando o usuário pedir push.
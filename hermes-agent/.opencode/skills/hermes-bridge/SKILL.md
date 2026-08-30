---
name: hermes-bridge
description: Use when working inside hermes-agent repo via opencode. Triggers on hermes-agent, gateway, skills, toolsets.
---

# Hermes-Agent Bridge (Project)

This is the project-level companion to the global `hermes` skill. Use it when you are inside `hermes-agent` via opencode.

## When to Use

- Editing `run_agent.py`, `cli.py`, `gateway/`, `tools/`, `hermes_cli/`, `tui_gateway/`, `plugins/`
- Working with Hermes toolsets (`toolsets.py`), prompt caching, delegation, cron, kanban

## References

- `references.hermes-docs` → `./docs` (architecture)
- `references.hermes-skills` → `./skills` (bundled skills)
- `AGENTS.md` is auto-loaded via `instructions: ["AGENTS.md"]` in `opencode.jsonc`

## Procedure

1. Read `AGENTS.md` for the narrow-waist / prompt-caching invariants before adding a core tool
2. Prefer CLI+skill > service-gated tool > plugin > MCP > core tool (Footprint Ladder)
3. Use `get_hermes_home()` not `Path.home() / ".hermes"` (profile-safe) — Windows home is `%LOCALAPPDATA%\hermes`

## Pitfalls

- Don't break prompt caching: no mid-conversation toolset swaps or context mutations
- Tests: use `scripts/run_tests.sh` not bare `pytest`
- Verify with `opencode mcp list` that `hermes` MCP is connected before using hermes_* tools

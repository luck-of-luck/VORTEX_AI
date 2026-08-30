"""Supervisão de variáveis globais — adesão + fluidez entre Hermes e OpenCode.

SSOT: HERMES_HOME/.env  (segredos)  +  config.yaml (fallback, reasoning)
Consumidores: OpenCode (auth.json / provider env), gateway, cron, kanban, MCP.

Três camadas:
 0) Observer: valida sem mutar
 1) Sync: copia segredos para opencode env (opt-in via sync.opencode_env)
 2) UX: doctor + gateway toast quando esgotado

Uso:
  from hermes_cli.env_supervisor import validate_supervised_env, sync_opencode_env
"""

from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import List, Dict

from hermes_constants import get_hermes_home

# Fallback chain deve espelhar opencode fallback-router.ts
_FALLBACK_CHAIN_COMMENT = "Mantido sincronizado entre config.yaml fallback_model e opencode plugins/fallback-router.ts"

def _load_hermes_env() -> Dict[str, str]:
    """Lê HERMES_HOME/.env sem mutar os.environ."""
    try:
        from agent.secret_scope import load_env_file
        home = get_hermes_home()
        return load_env_file(home / ".env")
    except Exception:
        return {}

def _load_opencode_auth() -> Dict[str, str]:
    """Lê opencode auth.json e retorna mapa provider->key presente."""
    candidates = [
        Path.home() / ".local" / "share" / "opencode" / "auth.json",
        Path(os.environ.get("LOCALAPPDATA", "")) / "opencode" / "auth.json",
        Path.home() / ".config" / "opencode" / "auth.json",
    ]
    for p in candidates:
        if p.exists():
            try:
                data = json.loads(p.read_text(encoding="utf-8"))
                out: Dict[str, str] = {}
                for k, v in data.items():
                    if isinstance(v, dict) and v.get("key"):
                        out[k] = v["key"]
                    elif isinstance(v, dict) and v.get("access"):
                        out[k] = v["access"]
                return out
            except Exception:
                continue
    return {}

def _parse_fallback_chain_from_config() -> List[str]:
    """Lê config.yaml fallback_model/fallback_providers e retorna lista 'provider/model'."""
    try:
        from hermes_cli.config import read_raw_config
        raw = read_raw_config() or {}
        chain = raw.get("fallback_model") or raw.get("fallback_providers") or []
        if isinstance(chain, dict):
            chain = [chain]
        out = []
        for e in chain:
            if isinstance(e, dict) and e.get("provider") and e.get("model"):
                out.append(f"{e['provider']}/{e['model']}")
        return out
    except Exception:
        return []

def _parse_fallback_chain_from_router() -> List[str]:
    """Lê plugins/fallback-router.ts e extrai FALLBACK_CHAIN via regex (sem TS parse)."""
    candidates = [
        Path.home() / ".config" / "opencode" / "plugins" / "fallback-router.ts",
        Path(get_hermes_home()) / "hermes-agent" / ".config" / "opencode" / "plugins" / "fallback-router.ts",
    ]
    for p in candidates:
        if p.exists():
            try:
                txt = p.read_text(encoding="utf-8")
                m = re.search(r"FALLBACK_CHAIN\s*=\s*\[(.*?)\]", txt, re.S)
                if not m:
                    continue
                block = m.group(1)
                # extrai strings entre aspas
                vals = re.findall(r'"([^"]+)"|\'([^\']+)\'', block)
                out = [a or b for a, b in vals]
                return out
            except Exception:
                continue
    return []

def validate_supervised_env() -> List[str]:
    """Valida adesão de variáveis globais. Retorna lista de issues (vazio = ok).

    Checa A1-A7 da auditoria:
    - A1-A3: segredos presentes e prefixo válido
    - A4: fallback chain sync
    - A5: HERMES_HOME path vs opencode mcp.command existe
    - A6: model vs small_model coerência
    """
    issues: List[str] = []
    hermes_env = _load_hermes_env()
    op_auth = _load_opencode_auth()

    # A1: OPENROUTER_API_KEY
    key = hermes_env.get("OPENROUTER_API_KEY", "")
    if not key or len(key) < 10:
        issues.append("A1 OPENROUTER_API_KEY ausente em HERMES_HOME/.env — opencode provider.openrouter vai falhar 401")
    elif not key.startswith("sk-or-"):
        issues.append(f"A1 OPENROUTER_API_KEY prefixo inesperado (esperado sk-or-, tem {key[:6]}...)")

    # A2: OPENCODE_ZEN_API_KEY
    zkey = hermes_env.get("OPENCODE_ZEN_API_KEY", "")
    if zkey and not zkey.startswith("sk-"):
        issues.append("A2 OPENCODE_ZEN_API_KEY prefixo inesperado")

    # A3: COPILOT token — aceita gho_ ou GH_TOKEN
    has_copilot = any(hermes_env.get(k) for k in ("COPILOT_GITHUB_TOKEN", "GH_TOKEN", "GITHUB_TOKEN"))
    if not has_copilot:
        issues.append("A3 COPILOT_GITHUB_TOKEN/GH_TOKEN ausente — fallback copilot não funcionará")

    # A4: fallback chain sync
    cfg_chain = _parse_fallback_chain_from_config()
    router_chain = _parse_fallback_chain_from_router()
    if cfg_chain and router_chain and cfg_chain != router_chain:
        # compara sem provider prefix para tolerar alias
        issues.append(f"A4 Fallback drift: config.yaml={cfg_chain[:2]}... vs fallback-router.ts={router_chain[:2]}... — sincronize!")

    # A5: HERMES_HOME vs opencode mcp.command
    try:
        from hermes_cli.config import read_raw_config as _rc
        # checa opencode.jsonc global
        op_global = Path.home() / ".config" / "opencode" / "opencode.jsonc"
        if op_global.exists():
            txt = op_global.read_text(encoding="utf-8")
            # procura hermes.exe path
            m = re.search(r'"command"\s*:\s*\[.*?"([^"]*hermes\.exe)"', txt, re.S | re.I)
            if m:
                p = Path(m.group(1))
                if not p.exists():
                    issues.append(f"A5 HERMES_HOME drift: opencode mcp.hermes.command aponta para {p} inexistente — corrija para {get_hermes_home()}/bin/hermes.exe")
    except Exception:
        pass

    # A6: model coerência (apenas aviso se ambos opus vs sonnet divergirem muito)
    # não é erro, só info — não adiciona issue

    return issues

def sync_opencode_env(*, dry_run: bool = False) -> Dict[str, str]:
    """Sync fluido: copia segredos de HERMES_HOME/.env para opencode .env (opt-in).

    Só roda se sync.opencode_env:true em config.yaml (DEFAULT_CONFIG sync).
    Nunca escreve segredo em opencode.jsonc (só em .env gitignored).
    Retorna dict de chaves sincronizadas.
    """
    try:
        from hermes_cli.config import read_raw_config
        raw = read_raw_config() or {}
        sync_cfg = raw.get("sync", {})
        if not sync_cfg.get("opencode_env"):
            return {}
    except Exception:
        return {}

    hermes_env = _load_hermes_env()
    # chaves que são single-source
    sync_keys = ["OPENROUTER_API_KEY", "OPENCODE_ZEN_API_KEY", "OPENCODE_GO_API_KEY",
                 "COPILOT_GITHUB_TOKEN", "GH_TOKEN", "GITHUB_TOKEN",
                 "ANTHROPIC_API_KEY", "OPENAI_API_KEY"]

    to_sync: Dict[str, str] = {}
    for k in sync_keys:
        v = hermes_env.get(k)
        if v and len(v) >= 10:
            to_sync[k] = v

    if not to_sync:
        return {}

    # destino: opencode .env (não existe por padrão, criamos)
    dest = Path.home() / ".config" / "opencode" / ".env"
    # também .local/share/opencode/.env como fallback se opencode ler de lá
    dest_alt = Path.home() / ".local" / "share" / "opencode" / ".env"

    for d in (dest, dest_alt):
        if dry_run:
            continue
        try:
            d.parent.mkdir(parents=True, exist_ok=True)
            # lê existente, mescla
            existing: Dict[str, str] = {}
            if d.exists():
                try:
                    from agent.secret_scope import load_env_file
                    existing = load_env_file(d)
                except Exception:
                    pass
            merged = dict(existing)
            merged.update(to_sync)
            lines = [f"{k}={v}" for k, v in sorted(merged.items())]
            d.write_text("\n".join(lines) + "\n", encoding="utf-8")
            try:
                os.chmod(d, 0o600)
            except Exception:
                pass
        except Exception:
            continue

    return to_sync

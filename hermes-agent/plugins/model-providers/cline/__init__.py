"""Cline provider profile.

Cline (usage-billing) exposes an OpenAI-compatible Chat Completions API at
https://api.cline.bot/api/v1 that aggregates models from many providers under
the ``provider/model-name`` convention (the same format OpenRouter uses).

Model IDs are passed verbatim to the ``model`` request field, so Hermes routes
any ``cline/<provider>/<model>`` selection straight through. Examples:

    model: cline/anthropic/claude-sonnet-4-6
    model: cline/minimax/minimax-m2.5
    model: cline/deepseek/deepseek-chat

Attribution headers are sent on every request so Cline can trace the traffic
origin, matching what the OpenRouter / OpenCode Zen profiles already do.
"""

from providers import register_provider
from providers.base import ProviderProfile

from hermes_cli import __version__ as _HERMES_VERSION

_ATTRIBUTION_HEADERS = {
    "HTTP-Referer": "https://hermes-agent.nousresearch.com",
    "X-Title": "Hermes Agent",
    "User-Agent": f"HermesAgent/{_HERMES_VERSION}",
}

cline = ProviderProfile(
    name="cline",
    aliases=("cliner", "cline-api", "cline-ai"),
    display_name="Cline",
    description="Cline (usage-billing) — unified API for 200+ models",
    signup_url="https://app.cline.bot",
    env_vars=("CLINE_API_KEY",),
    base_url="https://api.cline.bot/api/v1",
    models_url="https://api.cline.bot/api/v1/models",
    default_headers=dict(_ATTRIBUTION_HEADERS),
    supports_vision=True,
    supports_vision_tool_messages=True,
    fallback_models=(
        "anthropic/claude-sonnet-4-6",
        "openai/gpt-4o",
        "google/gemini-2.5-pro",
        "deepseek/deepseek-chat",
        "minimax/minimax-m2.5",
    ),
)

register_provider(cline)
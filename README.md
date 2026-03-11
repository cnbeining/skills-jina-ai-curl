# skills-jina-ai-curl

Repository for the `jina-ai-curl` skill.

The skill lives in [`jina-ai-curl/`](./jina-ai-curl) and teaches Codex or Claude Code to use `r.jina.ai` and `s.jina.ai` with `curl` as a lightweight fallback or preferred path for web fetch and web search in environments with odd firewall, proxy, or browser-tooling issues.

## What it includes

- `jina-ai-curl/SKILL.md`: trigger description and workflow guidance
- `jina-ai-curl/scripts/jina-curl.sh`: reusable `curl` wrapper for fetch and search
- `jina-ai-curl/references/jina-http.md`: Jina endpoint notes, headers, params, and raw curl examples
- `jina-ai-curl/agents/openai.yaml`: UI metadata for OpenAI-compatible skill surfaces

## Auth behavior

- `r.jina.ai` works with or without auth.
- `s.jina.ai` is treated as auth-required.
- The wrapper script uses the first populated token from `JINA_API_KEY`, `JINA_API_TOKEN`, or `JINA_TOKEN`.

## Quick examples

```bash
./jina-ai-curl/scripts/jina-curl.sh fetch "https://example.com"

./jina-ai-curl/scripts/jina-curl.sh search "jina reader api" \
  -G --data-urlencode "count=5"
```

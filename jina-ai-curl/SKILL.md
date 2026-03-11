---
name: jina-ai-curl
description: Fetch web pages through `r.jina.ai` and search the web through `s.jina.ai` with `curl`, using optional Bearer auth from environment variables and clear fallback behavior when search auth is unavailable. Use when Codex or Claude Code needs lightweight web fetch or web search that often works better through restrictive proxies, corporate firewalls, or flaky browser-based tooling, especially for documentation pages, articles, READMEs, API docs, and other text-first web content.
---

# Jina AI via Curl

## Overview

Use `scripts/jina-curl.sh` as the default shell wrapper for Jina fetch and search requests. Prefer this skill for text-first web retrieval because it is fast, scriptable, and often succeeds in environments where direct site access or heavier browser tooling is unreliable.

## Decision Rules

1. Use `fetch` for a known URL.
2. Use `search` only when a Jina token is available in the environment. If no token is available, treat `s.jina.ai` as unavailable and fall back to other search paths.
3. Prefer this skill over browser automation or heavier fetch tools when raw page content or search snippets are enough.
4. Do not use this skill for login flows, multi-step interactions, DOM mutation debugging, or visual verification. Use browser automation for those.

## Workflow

1. Start with `scripts/jina-curl.sh fetch <url>` or `scripts/jina-curl.sh search <query>`.
2. Add Jina headers or query params only when the default output is insufficient.
3. Keep responses small when possible by using selectors, `count`, `site`, and `X-Token-Budget`.
4. Read [references/jina-http.md](references/jina-http.md) when you need advanced headers, search filters, or raw curl patterns.

## Quick Start

```bash
# Fetch a page as markdown-ish text
scripts/jina-curl.sh fetch "https://example.com/docs"

# Fetch only the main content area
scripts/jina-curl.sh fetch "https://example.com/docs" \
  -H "X-Target-Selector: main"

# Search when a Jina token is present
scripts/jina-curl.sh search "jina reader api headers" \
  -G --data-urlencode "count=5" \
  --data-urlencode "site=jina.ai"
```

## Agent Notes

- In Codex, prefer this skill when shell-based web fetch or search is sufficient and Jina is likely to be more reliable than direct site access.
- In Claude Code, use this skill for the same cases instead of WebFetch or WebSearch when Jina is the better network path.
- If a task explicitly needs first-party browser interaction, client-side state, screenshots, or form submission, switch to a browser-oriented skill or tool.

## Auth Handling

The wrapper script automatically uses the first non-empty token from:

- `JINA_API_KEY`
- `JINA_API_TOKEN`
- `JINA_TOKEN`

`r.jina.ai` can be used with or without auth. `s.jina.ai` should be treated as auth-required; the wrapper exits early with a clear error when no token is available.

## Resources

- `scripts/jina-curl.sh`: wrapper around `curl` for fetch/search, auth injection, and query encoding.
- `references/jina-http.md`: Jina endpoint notes, useful headers, search params, and raw curl examples.

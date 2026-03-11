# Jina HTTP Reference

## Endpoints

- Fetch: `GET https://r.jina.ai/` with `url=<target-url>` as a query parameter.
- Search: `GET https://s.jina.ai/{query}` where the query is URL-encoded in the path.
- Docs used for this skill:
  - `https://r.jina.ai/openapi.json`
  - `https://s.jina.ai/openapi.json`

In practice, the wrapper uses the path form `https://r.jina.ai/http://<encoded-target-url>` for fetches because it works reliably with `curl` in this environment.

## Auth

- Use `Authorization: Bearer <token>` when a token is available.
- Prefer these environment variables in order:
  - `JINA_API_KEY`
  - `JINA_API_TOKEN`
  - `JINA_TOKEN`
- Treat `s.jina.ai` as unavailable when no token is set.

## Default Wrapper Behavior

`scripts/jina-curl.sh` adds:

- `--fail-with-body`
- `--silent`
- `--show-error`
- `--location`
- `--compressed`
- `X-Respond-With: markdown` by default
- `Authorization: Bearer ...` when a token is present

Optional environment overrides:

- `JINA_ACCEPT`
- `JINA_RESPOND_WITH`
- `JINA_TOKEN_BUDGET`

## Common Fetch Patterns

```bash
# Basic fetch
scripts/jina-curl.sh fetch "https://example.com/docs"

# Return only a specific section
scripts/jina-curl.sh fetch "https://example.com/docs" \
  -H "X-Target-Selector: main"

# Remove nav and footer noise
scripts/jina-curl.sh fetch "https://example.com/docs" \
  -H "X-Remove-Selector: nav,footer"

# Force a fresh crawl
scripts/jina-curl.sh fetch "https://example.com/docs" \
  -H "X-No-Cache: true"

# Wait for a rendered selector
scripts/jina-curl.sh fetch "https://example.com/docs" \
  -H "X-Wait-For-Selector: .content"
```

## Common Search Patterns

```bash
# Basic search
scripts/jina-curl.sh search "jina reader api headers"

# Limit the site and result count
scripts/jina-curl.sh search "reader api headers" \
  -G --data-urlencode "site=jina.ai" \
  --data-urlencode "count=5"

# News search
scripts/jina-curl.sh search "openai announcements" \
  -G --data-urlencode "type=news" \
  --data-urlencode "count=10"

# Provider and locale hints
scripts/jina-curl.sh search "rust wasm tutorial" \
  -G --data-urlencode "provider=google" \
  --data-urlencode "gl=us" \
  --data-urlencode "hl=en"
```

## Useful Fetch Headers

- `X-Respond-With`: `markdown`, `html`, `text`, `pageshot`, `screenshot`, `content`, `readerlm-v2`, `vlm`
- `X-Target-Selector`: return only a matching subtree
- `X-Wait-For-Selector`: wait for a selector before returning
- `X-Remove-Selector`: remove noisy elements
- `X-No-Cache`: bypass internal cache
- `X-Token-Budget`: reject overly large responses
- `X-Engine`: `browser`, `direct`, or `cf-browser-rendering`
- `X-Timeout`: timeout in seconds, up to 180
- `X-Proxy` and `X-Proxy-Url`: proxy controls

## Useful Search Parameters

- `count` or `num`: maximum results, up to 20
- `site`: restrict to one site
- `type`: `web`, `images`, or `news`
- `provider`: `google`, `bing`, or `reader`
- `gl`: country hint
- `hl`: language hint
- `location`: location hint
- `page`: result page
- `fallback`: allow fallback behavior
- `nfpr`: boolean search tuning flag
- explicit operators surfaced by the API: `ext`, `filetype`, `intitle`, `loc`, `site`

## Raw curl Examples

Use raw curl when the wrapper is too limiting for a one-off command.

```bash
# Fetch with official query-param form
curl --fail-with-body --silent --show-error --location --compressed \
  -H "X-Respond-With: markdown" \
  --get "https://r.jina.ai/" \
  --data-urlencode "url=https://example.com/docs"

# Fetch with the path form used by the wrapper
curl --fail-with-body --silent --show-error --location --compressed \
  -H "X-Respond-With: markdown" \
  "https://r.jina.ai/http://https%3A%2F%2Fexample.com%2Fdocs"

# Search with auth
curl --fail-with-body --silent --show-error --location --compressed \
  -H "Authorization: Bearer ${JINA_API_KEY}" \
  "https://s.jina.ai/jina%20reader%20api"
```

## When to Switch Tools

- Use browser tooling instead of Jina when the task needs login, clicking, forms, screenshots, or JS-state inspection.
- Use the platform's native browsing tool when the task requires that exact toolchain for policy, citations, or verification.

## Troubleshooting

- `400 Invalid URL` on fetch: prefer the path form used by `scripts/jina-curl.sh` instead of hand-building `?url=...`.
- `451 SecurityCompromiseError`: Jina is blocking that target domain. Switch to another fetch path for that site.

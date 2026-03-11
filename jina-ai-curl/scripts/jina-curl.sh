#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  jina-curl.sh fetch <url> [curl args...]
  jina-curl.sh search <query> [curl args...]

Environment:
  JINA_API_KEY        Preferred token source
  JINA_API_TOKEN      Alternate token source
  JINA_TOKEN          Alternate token source
  JINA_ACCEPT         Optional Accept header override
  JINA_RESPOND_WITH   Optional X-Respond-With header override
  JINA_TOKEN_BUDGET   Optional X-Token-Budget header value

Examples:
  jina-curl.sh fetch "https://example.com/docs"
  jina-curl.sh fetch "https://example.com/docs" -H "X-Target-Selector: main"
  jina-curl.sh search "jina reader api" -G --data-urlencode "count=5"
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 127
  fi
}

detect_token() {
  local name
  for name in JINA_API_KEY JINA_API_TOKEN JINA_TOKEN; do
    if [ -n "${!name:-}" ]; then
      printf '%s' "${!name}"
      return 0
    fi
  done
  return 1
}

urlencode() {
  require_cmd python3
  python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
}

build_common_args() {
  COMMON_ARGS=(
    --fail-with-body
    --silent
    --show-error
    --location
    --compressed
  )

  if [ -n "${JINA_ACCEPT:-}" ]; then
    COMMON_ARGS+=(-H "Accept: ${JINA_ACCEPT}")
  fi

  if [ -n "${JINA_RESPOND_WITH:-markdown}" ]; then
    COMMON_ARGS+=(-H "X-Respond-With: ${JINA_RESPOND_WITH:-markdown}")
  fi

  if [ -n "${JINA_TOKEN_BUDGET:-}" ]; then
    COMMON_ARGS+=(-H "X-Token-Budget: ${JINA_TOKEN_BUDGET}")
  fi

  if TOKEN="$(detect_token 2>/dev/null)"; then
    COMMON_ARGS+=(-H "Authorization: Bearer ${TOKEN}")
  fi
}

main() {
  local mode="${1:-}"
  shift || true

  if [ -z "${mode}" ] || [ "${mode}" = "help" ] || [ "${mode}" = "--help" ] || [ "${mode}" = "-h" ]; then
    usage
    exit 0
  fi

  require_cmd curl
  build_common_args

  case "${mode}" in
    fetch)
      if [ "$#" -lt 1 ]; then
        usage >&2
        exit 2
      fi
      local url="$1"
      shift
      curl "${COMMON_ARGS[@]}" "$@" "https://r.jina.ai/http://$(urlencode "${url}")"
      ;;
    search)
      if [ "$#" -lt 1 ]; then
        usage >&2
        exit 2
      fi
      if ! detect_token >/dev/null 2>&1; then
        printf 's.jina.ai requires a Jina token. Set JINA_API_KEY, JINA_API_TOKEN, or JINA_TOKEN.\n' >&2
        exit 2
      fi
      local query="$1"
      shift
      curl "${COMMON_ARGS[@]}" "$@" "https://s.jina.ai/$(urlencode "${query}")"
      ;;
    *)
      printf 'Unknown mode: %s\n\n' "${mode}" >&2
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"

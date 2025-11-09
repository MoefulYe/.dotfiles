#!/usr/bin/env bash
#
# downloader.sh
#
# Downloads a text resource. By default, prints the result to stdout.
# If --dest is provided, writes to that file atomically.
# Processor support has been removed; output is the raw download.
#
# Dependencies: curl
#
# Notes:
# - If --socks5 is provided, tries proxy first then falls back to direct.

set -eEuo pipefail
shopt -s failglob
umask 077

# -------- Constants (read-only) --------
readonly CONNECT_TIMEOUT="10"

# -------- Globals (mutable) --------
DEST_FILE=""
URL=""
SOCKS5_PROXY=""
QUIET=0

TMP_FILE=""

cleanup() {
  local rc=$?
  if [[ -n "${TMP_FILE:-}" && -f "${TMP_FILE}" ]]; then
    rm -f "$TMP_FILE" || true
  fi
  exit "$rc"
}
trap cleanup EXIT INT TERM

log_info()  { (( QUIET )) && return 0; printf '[*] %s\n' "$*"; }
log_warn()  { (( QUIET )) && return 0; printf '[!] %s\n' "$*"; }
log_error() { printf '[x] %s\n' "$*" >&2; }

usage() {
  cat >&2 <<'USAGE'
Usage: downloader [--dest <file>] [--socks5 <proxy>] [--quiet] <url>

Options:
  --dest <file>       Output file path (optional). If omitted, prints to stdout. Written atomically when provided.
  <url>               Source URL (required, positional).
  --socks5 <proxy>    SOCKS5 proxy (e.g., socks5://127.0.0.1:7890). If set, tries proxy first.
  --quiet             Suppress non-error logs (errors still shown on stderr).
  -h, --help          Show this help and exit.
 
Notes:
  - Prints to stdout by default when --dest is not provided.
USAGE
}

check_dependencies() {
  local missing=()
  local deps=(curl)
  local dep
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing+=("$dep")
    fi
  done
  if ((${#missing[@]} > 0)); then
    log_error "Missing dependencies: ${missing[*]}"; exit 127
  fi
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --dest)
        if [[ ${2-} && ${2:0:2} != "--" ]]; then DEST_FILE=$2; shift 2; else log_error "--dest requires a path"; usage; exit 2; fi ;;
      --socks5|--sock5)
        if [[ ${2-} && ${2:0:2} != "--" ]]; then SOCKS5_PROXY=$2; shift 2; else log_error "--socks5 requires a proxy"; usage; exit 2; fi ;;
      --quiet)
        QUIET=1; shift ;;
      -h|--help) usage; exit 0 ;;
      --*) log_error "Unknown option: $1"; usage; exit 2 ;;
      *)
        if [[ -z "$URL" ]]; then
          URL=$1; shift
        else
          log_error "Unexpected extra argument: $1"; usage; exit 2
        fi
        ;;
    esac
  done

  if [[ -z "$URL" ]]; then log_error "<url> is required"; usage; exit 2; fi
}

fetch_via() {
  local mode=${1:-direct}
  local -a args=("--fail" "-sS" "-L" "--connect-timeout" "$CONNECT_TIMEOUT" "$URL")
  if [[ "$mode" == proxy ]]; then
    if [[ -n "$SOCKS5_PROXY" ]]; then
      args=("--fail" "-sS" "-L" "--connect-timeout" "$CONNECT_TIMEOUT" -x "$SOCKS5_PROXY" "$URL")
    else
      return 2
    fi
  fi
  curl "${args[@]}"
}

main() {
  check_dependencies
  parse_args "$@"
  log_info "Downloading..."

  # Prepare temp file. If writing to a file, place temp alongside it for atomic mv.
  local dest_dir=""
  if [[ -n "$DEST_FILE" ]]; then
    # Expand leading ~ in DEST_FILE to support common usage
    DEST_FILE=${DEST_FILE/#\~/$HOME}
    dest_dir=$(dirname "$DEST_FILE")
    mkdir -p "$dest_dir"
    TMP_FILE=$(mktemp "$dest_dir/.downloader.XXXXXX")
  else
    TMP_FILE=""
  fi

  if [[ -n "$SOCKS5_PROXY" ]]; then
    log_info "Trying proxy: ${SOCKS5_PROXY}"
    if [[ -n "$DEST_FILE" ]]; then
      if fetch_via proxy >"$TMP_FILE"; then
        log_info "Downloaded via proxy."
      else
        log_warn "Proxy failed; fallback to direct."
        fetch_via direct >"$TMP_FILE"
        log_info "Downloaded directly." 
      fi
    else
      if fetch_via proxy; then
        log_info "Downloaded via proxy."
      else
        log_warn "Proxy failed; fallback to direct."
        fetch_via direct
        log_info "Downloaded directly."
      fi
    fi
  else
    log_info "Direct download"
    if [[ -n "$DEST_FILE" ]]; then
      fetch_via direct >"$TMP_FILE"
      log_info "Downloaded directly."
    else
      fetch_via direct
      log_info "Downloaded directly."
    fi
  fi

  if [[ -n "$DEST_FILE" ]]; then
    chmod 0644 "$TMP_FILE"
    mv -f "$TMP_FILE" "$DEST_FILE"
    TMP_FILE=""
    log_info "Wrote ${DEST_FILE}"
  else
    # No destination: content already printed to stdout
    :
  fi
}

main "$@"

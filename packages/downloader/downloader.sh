#!/usr/bin/env bash
#
# downloader.sh
#
# Downloads a text resource and writes to a destination file atomically.
# If a processor command is provided after "--", the downloaded content
# is piped into the processor and the processor's stdout is written. If no
# processor is provided, the raw download is written.
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

TMP_FILE=""

cleanup() {
  local rc=$?
  if [[ -n "${TMP_FILE:-}" && -f "${TMP_FILE}" ]]; then
    rm -f "$TMP_FILE" || true
  fi
  exit "$rc"
}
trap cleanup EXIT INT TERM

log_info()  { printf '[*] %s\n' "$*" >&2; }
log_warn()  { printf '[!] %s\n' "$*" >&2; }
log_error() { printf '[x] %s\n' "$*" >&2; }

usage() {
  cat <<'USAGE'
Usage: downloader --dest <file> --url <url> [--socks5 <proxy>] [-- CMD [ARGS...]]

Options:
  --dest <file>       Output file path (required). Written atomically.
  --url <url>         Source URL (required).
  --socks5 <proxy>    SOCKS5 proxy (e.g., socks5://127.0.0.1:7890). If set, tries proxy first.
  -h, --help          Show this help and exit.

Processor:
  - If provided after "--", downloader pipes the fetched content to CMD.
  - The output of CMD becomes the file content.
  - If omitted, the raw fetched content is written.
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
      --url)
        if [[ ${2-} && ${2:0:2} != "--" ]]; then URL=$2; shift 2; else log_error "--url requires a value"; usage; exit 2; fi ;;
      --socks5|--sock5)
        if [[ ${2-} && ${2:0:2} != "--" ]]; then SOCKS5_PROXY=$2; shift 2; else log_error "--socks5 requires a proxy"; usage; exit 2; fi ;;
      -h|--help) usage; exit 0 ;;
      --) shift; break ;;
      *) log_error "Unknown option: $1"; usage; exit 2 ;;
    esac
  done

  if [[ -z "$DEST_FILE" ]]; then log_error "--dest is required"; usage; exit 2; fi
  if [[ -z "$URL" ]]; then log_error "--url is required"; usage; exit 2; fi
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
  # Remaining args (if any) are the processor command
  local -a PROCESS_CMD=()
  if (($# > 0)); then
    PROCESS_CMD=("$@")
  fi
  log_info "Downloading..."

  local dest_dir
  dest_dir=$(dirname "$DEST_FILE")
  mkdir -p "$dest_dir"
  TMP_FILE=$(mktemp "$dest_dir/.downloader.XXXXXX")

  if [[ -n "$SOCKS5_PROXY" ]]; then
    log_info "Trying proxy: ${SOCKS5_PROXY}"
    if ((${#PROCESS_CMD[@]} > 0)); then
      if fetch_via proxy | "${PROCESS_CMD[@]}" >"$TMP_FILE"; then
        log_info "Downloaded via proxy (processed)."
      else
        log_warn "Proxy failed; fallback to direct."
        fetch_via direct | "${PROCESS_CMD[@]}" >"$TMP_FILE"
        log_info "Downloaded directly (processed)."
      fi
    else
      if fetch_via proxy >"$TMP_FILE"; then
        log_info "Downloaded via proxy."
      else
        log_warn "Proxy failed; fallback to direct."
        fetch_via direct >"$TMP_FILE"
        log_info "Downloaded directly."
      fi
    fi
  else
    log_info "Direct download"
    if ((${#PROCESS_CMD[@]} > 0)); then
      fetch_via direct | "${PROCESS_CMD[@]}" >"$TMP_FILE"
      log_info "Downloaded directly (processed)."
    else
      fetch_via direct >"$TMP_FILE"
      log_info "Downloaded directly."
    fi
  fi

  chmod 0644 "$TMP_FILE"
  mv -f "$TMP_FILE" "$DEST_FILE"
  TMP_FILE=""
  log_info "Wrote ${DEST_FILE}"
}

main "$@"

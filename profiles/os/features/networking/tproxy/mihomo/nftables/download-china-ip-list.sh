#!/usr/bin/env bash
#
# download-china-ip-list.sh
#
# Download China IPv4/IPv6 CIDR lists and generate nftables set definitions.
# Uses the shared downloader to fetch lists. Writes atomically to --dest.
#
# Dependencies: sed, awk, downloader
#
# Compatibility:
# - Tested against common shells and tools on NixOS, macOS (Darwin), Ubuntu, Debian.
# - Uses only POSIX-compatible sed/awk features to avoid GNU/BSD differences.
#
# Notes:
# - This script no longer accepts URL or set-name options; they are constants.
# - It first attempts primary URLs, then falls back to mirrors on failure.

set -eEuo pipefail
shopt -s failglob
umask 077

# -------- Constants (read-only) --------
declare -r URL_V4_PRIMARY="https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt"
declare -r URL_V6_PRIMARY="https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute_v6.txt"
declare -r URL_V4_FALLBACK="https://hub.gitmirror.com/https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt"
declare -r URL_V6_FALLBACK="https://hub.gitmirror.com/https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute_v6.txt"
declare -r SET_V4="china-ip-list-v4"
declare -r SET_V6="china-ip-list-v6"

# -------- Globals (mutable) --------
DEST=""
SOCKS5_PROXY=""

TMP_OUT_FILE=""

cleanup() {
  local rc=$?
  if [[ -n "${TMP_OUT_FILE:-}" && -f "${TMP_OUT_FILE}" ]]; then
    rm -f -- "$TMP_OUT_FILE" || true
  fi
  exit "$rc"
}
trap cleanup EXIT INT TERM

log_info()  { printf '[*] %s\n' "$*" >&2; }
log_warn()  { printf '[!] %s\n' "$*" >&2; }
log_error() { printf '[x] %s\n' "$*" >&2; }

usage() {
  cat <<'USAGE'
Usage: download-china-ip-list --dest <output-file> [--socks5 <proxy>] [-h|--help]

Options:
  --dest <output-file>            Destination file path (required). Written atomically.
  --socks5 <proxy>                SOCKS5 proxy (e.g., socks5://127.0.0.1:7890). If set, try primary via proxy, else use fallback directly.
  -h, --help                      Show this help and exit.
USAGE
}

check_dependencies() {
  local missing=()
  local deps=(sed awk downloader)
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
        if [[ ${2-} && ${2:0:1} != '-' ]]; then DEST=${2/#\~/$HOME}; shift 2; else log_error "--dest requires a path"; usage; exit 2; fi ;;
      --socks5)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then SOCKS5_PROXY=$2; shift 2; else log_error "--socks5 requires a proxy"; usage; exit 2; fi ;;
      -h|--help)
        usage; exit 0 ;;
      *)
        log_error "Unknown option: $1"; usage; exit 2 ;;
    esac
  done

  if [[ -z "$DEST" ]]; then log_error "--dest is required"; usage; exit 2; fi
}

fetch_stdout_with_fallback() {
  # Args: primary_url fallback_url
  local primary_url=${1:?}
  local fallback_url=${2:?}
  # Behavior:
  # - If SOCKS5 provided: try primary via proxy; on failure, use fallback directly.
  # - If no SOCKS5: skip primary and go straight to fallback.
  if [[ -n "$SOCKS5_PROXY" ]]; then
    if downloader --quiet --socks5 "$SOCKS5_PROXY" "$primary_url" 2>/dev/null; then
      return 0
    fi
    log_warn "Primary via SOCKS5 failed; trying fallback: $fallback_url"
    downloader --quiet "$fallback_url" 2>/dev/null
  else
    downloader --quiet "$fallback_url" 2>/dev/null
  fi
}

format_set_block() {
  # Args: set_name ip_family; reads CIDRs from stdin
  local set_name=${1:?}
  local family=${2:?} # ipv4_addr | ipv6_addr
  printf 'set %s { type %s; flags interval; elements = {\n' "$set_name" "$family"
  # Remove empty/whitespace-only lines, format with trailing commas, strip final trailing comma
  sed '/^[[:space:]]*$/d' | awk '{printf "        %s,\n", $0}' | sed -e '$s/, *$//'
  printf '\n  } }\n'
}

main() {
  check_dependencies
  parse_args "$@"

  # Prepare temp output file next to DEST; do not create directories here
  TMP_OUT_FILE=$(mktemp "${DEST}.temp.XXXXXX")

  log_info "Building nftables sets from remote lists..."
  {
    fetch_stdout_with_fallback "$URL_V4_PRIMARY" "$URL_V4_FALLBACK" \
      | format_set_block "$SET_V4" "ipv4_addr"
    fetch_stdout_with_fallback "$URL_V6_PRIMARY" "$URL_V6_FALLBACK" \
      | format_set_block "$SET_V6" "ipv6_addr"
  } >"$TMP_OUT_FILE"

  chmod 0644 "$TMP_OUT_FILE"
  mv -f -- "$TMP_OUT_FILE" "$DEST"
  TMP_OUT_FILE=""
  log_info "Wrote $DEST"
}

main "$@"

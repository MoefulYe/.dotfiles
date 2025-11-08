#!/usr/bin/env bash
#
# download-china-ip-list.sh
#
# Download China IPv4/IPv6 CIDR lists and generate nftables set definitions.
# Writes atomically to the specified output file.
#
# Dependencies: curl, sed, awk
#
# Compatibility:
# - Tested against common shells and tools on NixOS, macOS (Darwin), Ubuntu, Debian.
# - Uses only POSIX-compatible sed/awk features to avoid GNU/BSD differences.
#
# Notes:
# - If --socks5 is provided, attempts proxy fetch from the primary URL first.
#   If proxy fetch fails, falls back to the fallback URL without proxy.

set -eEuo pipefail
shopt -s failglob
umask 077

# -------- Constants (read-only) --------
declare -r DEFAULT_URL_V4_PRIMARY="https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt"
declare -r DEFAULT_URL_V6_PRIMARY="https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute_v6.txt"
declare -r CONNECT_TIMEOUT="10"

# -------- Globals (mutable) --------
OUT_DIR=""
OUT_NAME=""
SET_V4=""
SET_V6=""
URL_V4_PRIMARY="${DEFAULT_URL_V4_PRIMARY}"
URL_V6_PRIMARY="${DEFAULT_URL_V6_PRIMARY}"
URL_V4_FALLBACK=""
URL_V6_FALLBACK=""
SOCKS5_PROXY=""
TRY_PROXY=false

TMP_DIR=""
TMP_OUT_FILE=""

cleanup() {
  local rc=$?
  if [[ -n "${TMP_OUT_FILE:-}" && -f "${TMP_OUT_FILE}" ]]; then
    rm -f -- "$TMP_OUT_FILE" || true
  fi
  if [[ -n "${TMP_DIR:-}" && -d "${TMP_DIR}" ]]; then
    rm -rf -- "$TMP_DIR" || true
  fi
  exit "$rc"
}
trap cleanup EXIT INT TERM

log_info()  { printf '[*] %s\n' "$*" >&2; }
log_warn()  { printf '[!] %s\n' "$*" >&2; }
log_error() { printf '[x] %s\n' "$*" >&2; }

usage() {
  cat <<'USAGE'
Usage: download-china-ip-list \
  --dir <output-dir> \
  --out-name <filename> \
  --set-v4 <nft_set_name_v4> \
  --set-v6 <nft_set_name_v6> \
  [--url-v4 <primary_v4_url>] [--url-v6 <primary_v6_url>] \
  [--url-v4-fallback <fallback_v4_url>] [--url-v6-fallback <fallback_v6_url>] \
  [--socks5 <socks5://host:port>] \
  [-h|--help]

Options:
  --dir <output-dir>              Directory to write the output file (required).
  --out-name <filename>           Output file name (required).
  --set-v4 <name>                 nftables set name for IPv4 (required).
  --set-v6 <name>                 nftables set name for IPv6 (required).
  --url-v4 <url>                  Primary IPv4 list URL (default: mayaxcn).
  --url-v6 <url>                  Primary IPv6 list URL (default: mayaxcn).
  --url-v4-fallback <url>         Fallback IPv4 list URL (default: hub.gitmirror.com/<primary_v4_url>).
  --url-v6-fallback <url>         Fallback IPv6 list URL (default: hub.gitmirror.com/<primary_v6_url>).
  --socks5 <proxy>                SOCKS5 proxy URI. If provided, try proxy first then fallback.
  -h, --help                      Show this help and exit.
USAGE
}

check_dependencies() {
  local missing=()
  local deps=(curl sed awk)
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
      --dir)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then OUT_DIR=$2; shift 2; else log_error "--dir requires a value"; usage; exit 2; fi ;;
      --out-name)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then OUT_NAME=$2; shift 2; else log_error "--out-name requires a value"; usage; exit 2; fi ;;
      --set-v4)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then SET_V4=$2; shift 2; else log_error "--set-v4 requires a value"; usage; exit 2; fi ;;
      --set-v6)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then SET_V6=$2; shift 2; else log_error "--set-v6 requires a value"; usage; exit 2; fi ;;
      --url-v4)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then URL_V4_PRIMARY=$2; shift 2; else log_error "--url-v4 requires a URL"; usage; exit 2; fi ;;
      --url-v6)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then URL_V6_PRIMARY=$2; shift 2; else log_error "--url-v6 requires a URL"; usage; exit 2; fi ;;
      --url-v4-fallback)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then URL_V4_FALLBACK=$2; shift 2; else log_error "--url-v4-fallback requires a URL"; usage; exit 2; fi ;;
      --url-v6-fallback)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then URL_V6_FALLBACK=$2; shift 2; else log_error "--url-v6-fallback requires a URL"; usage; exit 2; fi ;;
      --socks5)
        if [[ ${2-} && ${2:0:1} != '-' ]]; then SOCKS5_PROXY=$2; TRY_PROXY=true; shift 2; else log_error "--socks5 requires a proxy URI"; usage; exit 2; fi ;;
      -h|--help)
        usage; exit 0 ;;
      *)
        log_error "Unknown option: $1"; usage; exit 2 ;;
    esac
  done

  if [[ -z "$OUT_DIR" ]]; then log_error "--dir is required"; usage; exit 2; fi
  if [[ -z "$OUT_NAME" ]]; then log_error "--out-name is required"; usage; exit 2; fi
  if [[ -z "$SET_V4" ]]; then log_error "--set-v4 is required"; usage; exit 2; fi
  if [[ -z "$SET_V6" ]]; then log_error "--set-v6 is required"; usage; exit 2; fi

  # Derive fallback URLs if not specified
  if [[ -z "$URL_V4_FALLBACK" ]]; then URL_V4_FALLBACK="https://hub.gitmirror.com/${URL_V4_PRIMARY}"; fi
  if [[ -z "$URL_V6_FALLBACK" ]]; then URL_V6_FALLBACK="https://hub.gitmirror.com/${URL_V6_PRIMARY}"; fi

  # Normalize OUT_DIR (expand leading ~)
  OUT_DIR=${OUT_DIR/#\~/$HOME}
}

fetch_into() {
  # Args: mode primary_url fallback_url dest_file
  # mode: proxy-first or fallback-only
  local mode=${1:?}
  local primary_url=${2:?}
  local fallback_url=${3:?}
  local dest_file=${4:?}

  : >"$dest_file"
  if [[ "$mode" == "proxy-first" ]]; then
    if [[ -n "$SOCKS5_PROXY" ]]; then
      log_info "(Proxy Mode) Fetch primary via proxy: $primary_url"
      if curl --fail -sS -L --connect-timeout "$CONNECT_TIMEOUT" -x "$SOCKS5_PROXY" \
        "$primary_url" >"$dest_file"; then
        return 0
      fi
      log_warn "Proxy fetch failed; falling back to direct mirror."
    fi
  else
    log_info "(Standard Mode) Skipping proxy logic."
  fi

  log_info "Fetch from mirror: $fallback_url"
  if ! curl --fail -sS -L --connect-timeout "$CONNECT_TIMEOUT" \
    "$fallback_url" >"$dest_file"; then
    return 1
  fi
}

format_set_block() {
  # Args: set_name ip_family input_file
  local set_name=${1:?}
  local family=${2:?} # ipv4_addr | ipv6_addr
  local in_file=${3:?}
  printf 'set %s { type %s; flags interval; elements = {\n' "$set_name" "$family"
  # Remove empty/whitespace-only lines, format with trailing commas, strip final trailing comma
  sed '/^[[:space:]]*$/d' "$in_file" | awk '{printf "        %s,\n", $0}' | sed -e '$s/, *$//'
  printf '\n  } }\n'
}

main() {
  check_dependencies
  parse_args "$@"

  # Prepare dirs/files
  mkdir -p -- "$OUT_DIR"
  TMP_DIR=$(mktemp -d "${OUT_DIR%/}/.china-ip.tmp.XXXXXX")
  TMP_OUT_FILE=$(mktemp "${OUT_DIR%/}/.china-ip.out.XXXXXX.nft")

  local mode="fallback-only"
  if [[ -n "$SOCKS5_PROXY" ]]; then mode="proxy-first"; fi

  local v4_file v6_file
  v4_file="$TMP_DIR/v4.txt"
  v6_file="$TMP_DIR/v6.txt"

  log_info "Downloading IPv4 list..."
  if ! fetch_into "$mode" "$URL_V4_PRIMARY" "$URL_V4_FALLBACK" "$v4_file"; then
    log_error "Failed to fetch IPv4 list from both primary and fallback."; exit 1
  fi

  log_info "Downloading IPv6 list..."
  if ! fetch_into "$mode" "$URL_V6_PRIMARY" "$URL_V6_FALLBACK" "$v6_file"; then
    log_error "Failed to fetch IPv6 list from both primary and fallback."; exit 1
  fi

  log_info "Formatting nftables set definitions..."
  {
    format_set_block "$SET_V4" "ipv4_addr" "$v4_file"
    format_set_block "$SET_V6" "ipv6_addr" "$v6_file"
  } >"$TMP_OUT_FILE"

  chmod 0644 "$TMP_OUT_FILE"
  mv -f -- "$TMP_OUT_FILE" "${OUT_DIR%/}/$OUT_NAME"
  TMP_OUT_FILE=""
  log_info "Wrote ${OUT_DIR%/}/$OUT_NAME"
}

main "$@"

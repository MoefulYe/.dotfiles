#!/usr/bin/env bash
#
# china-ip-updater.sh
#
# Refresh nftables China IP sets by downloading the latest CIDR lists
# and applying them to the specified table.
#
# Dependencies: nft, download-china-ip-list, coreutils
#
# Notes:
# - This updater may use a SOCKS5 proxy for the downloader if provided.
# - It is separate from service startup; proxy availability is expected.

set -eEuo pipefail
shopt -s failglob

TABLE_NAME="mihomo-tproxy"
OUT_DIR=""
OUT_NAME=""
SET_V4=""
SET_V6=""
SOCKS5=""

cleanup() { exit $?; }
trap cleanup EXIT INT TERM

log_info()  { printf '[*] %s\n' "$*" >&2; }
log_error() { printf '[x] %s\n' "$*" >&2; }

usage() {
  cat <<'USAGE'
Usage: china-ip-updater \
  --dir <output-dir> \
  --out-name <filename> \
  --set-v4 <setname_v4> \
  --set-v6 <setname_v6> \
  [--table-name <name>] \
  [--socks5 <socks5://host:port>] \
  [-h|--help]

Updates nftables sets for China IPs by fetching the latest lists and
applying them into the given table.
USAGE
}

check_dependencies() {
  local missing=()
  local deps=(nft download-china-ip-list)
  local dep
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then missing+=("$dep"); fi
  done
  if ((${#missing[@]} > 0)); then
    log_error "Missing dependencies: ${missing[*]}"; exit 127
  fi
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --dir) if [[ ${2-} && ${2:0:1} != '-' ]]; then OUT_DIR=${2/#\~/$HOME}; shift 2; else log_error "--dir requires a value"; usage; exit 2; fi ;;
      --out-name) if [[ ${2-} && ${2:0:1} != '-' ]]; then OUT_NAME=$2; shift 2; else log_error "--out-name requires a value"; usage; exit 2; fi ;;
      --set-v4) if [[ ${2-} && ${2:0:1} != '-' ]]; then SET_V4=$2; shift 2; else log_error "--set-v4 requires a value"; usage; exit 2; fi ;;
      --set-v6) if [[ ${2-} && ${2:0:1} != '-' ]]; then SET_V6=$2; shift 2; else log_error "--set-v6 requires a value"; usage; exit 2; fi ;;
      --table-name) if [[ ${2-} && ${2:0:1} != '-' ]]; then TABLE_NAME=$2; shift 2; else log_error "--table-name requires a value"; usage; exit 2; fi ;;
      --socks5) if [[ ${2-} && ${2:0:1} != '-' ]]; then SOCKS5=$2; shift 2; else log_error "--socks5 requires a proxy URI"; usage; exit 2; fi ;;
      -h|--help) usage; exit 0 ;;
      *) log_error "Unknown option: $1"; usage; exit 2 ;;
    esac
  done
  if [[ -z "$OUT_DIR" || -z "$OUT_NAME" || -z "$SET_V4" || -z "$SET_V6" ]]; then
    log_error "--dir, --out-name, --set-v4, --set-v6 are required"; usage; exit 2
  fi
}

run_downloader() {
  local -a args=(
    --dir "$OUT_DIR"
    --out-name "$OUT_NAME"
    --set-v4 "$SET_V4"
    --set-v6 "$SET_V6"
  )
  if [[ -n "$SOCKS5" ]]; then args+=(--socks5 "$SOCKS5"); fi
  download-china-ip-list "${args[@]}"
}

apply_sets() {
  local input_file="${OUT_DIR%/}/$OUT_NAME"
  if [[ ! -f "$input_file" ]]; then
    log_error "Input file not found: $input_file"; exit 1
  fi
  nft flush set inet "$TABLE_NAME" "$SET_V4" || true
  nft flush set inet "$TABLE_NAME" "$SET_V6" || true
  log_info "Applying sets into table: $TABLE_NAME"
  (
    echo "table inet $TABLE_NAME {"
    cat "$input_file"
    echo "}"
  ) | nft -f -
  log_info "China IP sets updated successfully."
}

main() {
  check_dependencies
  parse_args "$@"
  run_downloader
  apply_sets
}

main "$@"


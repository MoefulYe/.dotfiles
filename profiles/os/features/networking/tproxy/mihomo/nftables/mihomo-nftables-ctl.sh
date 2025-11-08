#!/usr/bin/env bash
#
# mihomo-nftables-ctl.sh
#
# Control utility to apply/remove the nftables ruleset for Mihomo TProxy.
# Ensures China IP list exists (generates if missing via download-china-ip-list),
# deletes any existing table, then applies the full ruleset from a table file.
#
# Dependencies: grep, nft
# Optional: download-china-ip-list
#
# Compatibility:
# - Works on NixOS, macOS (Darwin), Ubuntu, Debian.
# - Uses POSIX shell features and common utilities.

set -eEuo pipefail
shopt -s failglob

# -------- Globals (mutable) --------
SUBCMD=""
NFT_CMD="nft"
TABLE_NAME="mihomo-tproxy"
TABLE_FILE=""
CHINA_DIR=""
CHINA_NAME=""
SET_V4=""
SET_V6=""
DOWNLOADER_BIN="download-china-ip-list"
:

cleanup() {
  local rc=$?
  exit "$rc"
}
trap cleanup EXIT INT TERM

log_info()  { printf '[*] %s\n' "$*" >&2; }
log_warn()  { printf '[!] %s\n' "$*" >&2; }
log_error() { printf '[x] %s\n' "$*" >&2; }

usage() {
  cat <<'USAGE'
Usage: mihomo-nftables-ctl <up|down> [options]

Commands:
  up                       Ensure China list exists, replace table, apply rules.
  down                     Delete the nftables table if it exists.

Options:
  --nft <path>             Path to nft binary (default: nft from PATH).
  --table-name <name>      nftables table name (default: mihomo-tproxy).
  --table-file <file>      Path to nftables ruleset file (required for 'up').
  --china-dir <dir>        Directory containing the China IP list file (required for 'up').
  --china-name <file>      China IP list filename (required for 'up').
  --set-v4 <name>          China IPv4 set name (required for 'up' initial download).
  --set-v6 <name>          China IPv6 set name (required for 'up' initial download).
  --downloader <path>      download-china-ip-list binary (default: in PATH).
  -h, --help               Show this help and exit.
USAGE
}

check_dependencies() {
  local missing=()
  local deps=(grep)
  local dep
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then missing+=("$dep"); fi
  done
  if ! command -v "$NFT_CMD" >/dev/null 2>&1; then missing+=("nft"); fi
  if ((${#missing[@]} > 0)); then
    log_error "Missing dependencies: ${missing[*]}"; exit 127
  fi
}

parse_args() {
  if (($# == 0)); then usage; exit 2; fi
  SUBCMD=$1; shift || true
  case "$SUBCMD" in
    up|down) ;; 
    -h|--help) usage; exit 0 ;;
    *) log_error "Unknown command: $SUBCMD"; usage; exit 2 ;;
  esac

  while (($# > 0)); do
    case "$1" in
      --nft) if [[ ${2-} && ${2:0:1} != '-' ]]; then NFT_CMD=$2; shift 2; else log_error "--nft requires a path"; usage; exit 2; fi ;;
      --table-name) if [[ ${2-} && ${2:0:1} != '-' ]]; then TABLE_NAME=$2; shift 2; else log_error "--table-name requires a value"; usage; exit 2; fi ;;
      --table-file) if [[ ${2-} && ${2:0:1} != '-' ]]; then TABLE_FILE=$2; shift 2; else log_error "--table-file requires a file"; usage; exit 2; fi ;;
      --china-dir) if [[ ${2-} && ${2:0:1} != '-' ]]; then CHINA_DIR=${2/#\~/$HOME}; shift 2; else log_error "--china-dir requires a dir"; usage; exit 2; fi ;;
      --china-name) if [[ ${2-} && ${2:0:1} != '-' ]]; then CHINA_NAME=$2; shift 2; else log_error "--china-name requires a file name"; usage; exit 2; fi ;;
      --set-v4) if [[ ${2-} && ${2:0:1} != '-' ]]; then SET_V4=$2; shift 2; else log_error "--set-v4 requires a value"; usage; exit 2; fi ;;
      --set-v6) if [[ ${2-} && ${2:0:1} != '-' ]]; then SET_V6=$2; shift 2; else log_error "--set-v6 requires a value"; usage; exit 2; fi ;;
      --downloader) if [[ ${2-} && ${2:0:1} != '-' ]]; then DOWNLOADER_BIN=$2; shift 2; else log_error "--downloader requires a path"; usage; exit 2; fi ;;
      -h|--help) usage; exit 0 ;;
      *) log_error "Unknown option: $1"; usage; exit 2 ;;
    esac
  done

  if [[ "$SUBCMD" == "up" ]]; then
    if [[ -z "$TABLE_FILE" ]]; then log_error "--table-file is required for 'up'"; usage; exit 2; fi
    if [[ -z "$CHINA_DIR" || -z "$CHINA_NAME" ]]; then log_error "--china-dir and --china-name are required for 'up'"; usage; exit 2; fi
  fi
}

ensure_china_list() {
  local target_file="${CHINA_DIR%/}/$CHINA_NAME"
  if [[ -e "$target_file" ]]; then
    log_info "China IP list exists: $target_file"
    return 0
  fi

  if [[ -z "$SET_V4" || -z "$SET_V6" ]]; then
    log_error "China IP list missing and --set-v4/--set-v6 not provided for initial download"; exit 2
  fi

  local -a args=(
    --dir "$CHINA_DIR"
    --out-name "$CHINA_NAME"
    --set-v4 "$SET_V4"
    --set-v6 "$SET_V6"
  )
  log_info "China IP list not found; running downloader to initialize..."
  if ! "$DOWNLOADER_BIN" "${args[@]}"; then
    log_error "Downloader failed to initialize China IP list"; exit 1
  fi
  if [[ ! -e "$target_file" ]]; then
    log_error "Downloader ran but file still missing: $target_file"; exit 1
  fi
  log_info "Initialization complete: $target_file"
}

cmd_up() {
  check_dependencies
  ensure_china_list
  # best-effort removal
  if "$NFT_CMD" list tables | grep -q "$TABLE_NAME"; then
    if ! "$NFT_CMD" delete table inet "$TABLE_NAME"; then
      log_error "Failed to delete table 'inet $TABLE_NAME'"; exit 1
    fi
    log_info "Deleted existing table: inet $TABLE_NAME"
  else
    log_info "Table not present: inet $TABLE_NAME"
  fi
  if ! "$NFT_CMD" -f "$TABLE_FILE"; then
    log_error "Failed to apply ruleset: $TABLE_FILE"; exit 1
  fi
  log_info "Applied ruleset successfully."
}

cmd_down() {
  check_dependencies
  if "$NFT_CMD" list tables | grep -q "$TABLE_NAME"; then
    if ! "$NFT_CMD" delete table inet "$TABLE_NAME"; then
      log_error "Failed to delete table 'inet $TABLE_NAME'"; exit 1
    fi
    log_info "Deleted table: inet $TABLE_NAME"
  else
    log_info "Table not present; nothing to do: inet $TABLE_NAME"
  fi
}

main() {
  parse_args "$@"
  case "$SUBCMD" in
    up) cmd_up ;;
    down) cmd_down ;;
  esac
}

main "$@"

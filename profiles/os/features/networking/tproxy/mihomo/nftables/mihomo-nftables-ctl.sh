#!/usr/bin/env bash
#
# mihomo-nftables-ctl.sh
#
# Control utility to apply/remove the nftables ruleset for Mihomo TProxy.
# This script ONLY manages nftables rules: delete existing table, then apply
# the provided ruleset; or delete the table on 'down'. It no longer handles
# generating or ensuring China IP lists.
#
# Dependencies: grep, nft
#
# Compatibility:
# - Works on NixOS, macOS (Darwin), Ubuntu, Debian.
# - Uses POSIX shell features and common utilities.

set -eEuo pipefail
shopt -s failglob

# -------- Globals (mutable) --------
SUBCMD=""
TABLE_FILE=""
readonly TABLE_NAME="mihomo-tproxy"

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
  up                       Replace table (if present) and apply rules.
  down                     Delete the nftables table if it exists.

Options:
  --table-file <file>      Path to nftables ruleset file (required for 'up').
  -h, --help               Show this help and exit.
USAGE
}

check_dependencies() {
  local missing=()
  local deps=(grep nft)
  local dep
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then missing+=("$dep"); fi
  done
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
      --table-file) if [[ ${2-} && ${2:0:1} != '-' ]]; then TABLE_FILE=$2; shift 2; else log_error "--table-file requires a file"; usage; exit 2; fi ;;
      -h|--help) usage; exit 0 ;;
      *) log_error "Unknown option: $1"; usage; exit 2 ;;
    esac
  done

  if [[ "$SUBCMD" == "up" ]]; then
    if [[ -z "$TABLE_FILE" ]]; then log_error "--table-file is required for 'up'"; usage; exit 2; fi
  fi
}

cmd_up() {
  check_dependencies
  # best-effort removal
  if nft list tables | grep -q "$TABLE_NAME"; then
    if ! nft delete table inet "$TABLE_NAME"; then
      log_error "Failed to delete table 'inet $TABLE_NAME'"; exit 1
    fi
    log_info "Deleted existing table: inet $TABLE_NAME"
  else
    log_info "Table not present: inet $TABLE_NAME"
  fi
  if ! nft -f "$TABLE_FILE"; then
    log_error "Failed to apply ruleset: $TABLE_FILE"; exit 1
  fi
  log_info "Applied ruleset successfully."
}

cmd_down() {
  check_dependencies
  if nft list tables | grep -q "$TABLE_NAME"; then
    if ! nft delete table inet "$TABLE_NAME"; then
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

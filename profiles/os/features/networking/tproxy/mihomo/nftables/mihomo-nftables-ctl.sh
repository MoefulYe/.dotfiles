#!/usr/bin/env bash
#
# mihomo-nftables-ctl.sh
#
# Controls the mihomo-tproxy nftables table: bring it up or down.
# - Ensures the China IP list file exists
# - Applies the nftables ruleset or deletes the table accordingly.
#
# Dependencies: nft, coreutils, grep, china-ip-updater

set -eEuo pipefail
shopt -s failglob

NFT_TABLE_NAME="mihomo-tproxy"
CHINA_IP_LIST_FILE=""
TABLE_FILE=""
REMAINDER_ARGS=()

usage() {
  cat >&2 <<'USAGE'
Usage: mihomo-nftables-ctl {up|down} [options] [-- <initializer> [args...]]

Commands:
  up    Ensure IP list exists and apply nftables ruleset.
  down  Delete the nftables table if present.
Options (for 'up'):
  --list <file>       China IP list file (required).
  --table <file>      nftables rules file to apply (required).
  --table-name <name> Override table name (default: mihomo-tproxy).
USAGE
}

log_info()  { printf '[*] %s\n' "$*" >&2; }
log_warn()  { printf '[!] %s\n' "$*" >&2; }
log_error() { printf '[x] %s\n' "$*" >&2; }

parse_args() {
  local cmd=${1-}
  shift || true
  case "$cmd" in
    up)
      while (($# > 0)); do
        case "$1" in
          --list) CHINA_IP_LIST_FILE=$2; shift 2;;
          --table) TABLE_FILE=$2; shift 2;;
          --table-name) NFT_TABLE_NAME=$2; shift 2;;
          --) shift; REMAINDER_ARGS=("$@"); break;;
          -h|--help) usage; exit 0;;
          *) log_error "Unknown option: $1"; usage; exit 2;;
        esac
      done
      [[ -n "$CHINA_IP_LIST_FILE" && -n "$TABLE_FILE" ]] || { log_error "--list and --table are required for 'up'"; usage; exit 2; }
      ;;
    down)
      : ;;
    -h|--help|help|"")
      usage; exit 0 ;;
    *)
      log_error "Unknown command: $cmd"; usage; exit 2 ;;
  esac
  echo "$cmd"
}

main() {
  local cmd
  cmd=$(parse_args "$@")
  case "$cmd" in
    up)
      log_info "Applying $NFT_TABLE_NAME nftables rules..."
      if [[ ! -f "$CHINA_IP_LIST_FILE" ]]; then
        if ((${#REMAINDER_ARGS[@]} > 0)); then
          log_warn "IP list missing; initializing via: ${REMAINDER_ARGS[*]}"
          ensure-exist "$CHINA_IP_LIST_FILE" "${REMAINDER_ARGS[@]}"
        else
          log_error "IP list '$CHINA_IP_LIST_FILE' missing and no initializer provided (use -- <cmd> [args...])"; exit 1
        fi
      fi
      nft delete table inet "$NFT_TABLE_NAME" || true
      nft -f "$TABLE_FILE"
      log_info "SUCCESS: $NFT_TABLE_NAME rules applied."
      ;;
    down)
      log_info "Deleting $NFT_TABLE_NAME table if present..."
      if nft list tables | grep -q "$NFT_TABLE_NAME"; then
        nft delete table inet "$NFT_TABLE_NAME"
        log_info "SUCCESS: $NFT_TABLE_NAME table deleted."
      else
        log_info "Table $NFT_TABLE_NAME not present; nothing to do."
      fi
      ;;
  esac
}

main "$@"

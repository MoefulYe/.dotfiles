#!/usr/bin/env bash
#
# china-ip-updater.sh
#
# Downloads China IPv4/IPv6 CIDR lists, formats them into nftables set
# definitions, writes atomically to the destination, and applies them.
#
# Dependencies: downloader, awk, nft, coreutils

set -eEuo pipefail
shopt -s failglob
umask 077

DEST_FILE=""
V4_URL_PRIMARY=""
V6_URL_PRIMARY=""
V4_URL_FALLBACK=""
V6_URL_FALLBACK=""
NFT_SET_V4=""
NFT_SET_V6=""
SOCKS5_PROXY=""
NFT_TABLE_NAME="mihomo-tproxy"

log_info()  { printf '[*] %s\n' "$*" >&2; }
log_warn()  { printf '[!] %s\n' "$*" >&2; }
log_error() { printf '[x] %s\n' "$*" >&2; }

cleanup() {
  local rc=$?
  [[ -n ${TMP_V4:-} && -f ${TMP_V4:-} ]] && rm -f "$TMP_V4" || true
  [[ -n ${TMP_V6:-} && -f ${TMP_V6:-} ]] && rm -f "$TMP_V6" || true
  [[ -n ${TMP_OUT:-} && -f ${TMP_OUT:-} ]] && rm -f "$TMP_OUT" || true
  exit "$rc"
}
trap cleanup EXIT INT TERM

format_elements() {
  # Formats stdin lines into indented nft elements, last line without comma
  awk 'NF{a[++n]=$0} END{for(i=1;i<=n;i++){printf "        %s", a[i]; if(i<n)printf ",\n"; else printf "\n"}}'
}

fetch_with_fallback() {
  # $1: url_primary, $2: url_fallback, $3: dest file
  local primary=$1 fallback=$2 dest=$3
  if [[ -n "$SOCKS5_PROXY" ]]; then
    if downloader --dest "$dest" --url "$primary" --socks5 "$SOCKS5_PROXY"; then
      return 0
    fi
    log_warn "Primary failed; trying fallback: $fallback"
    downloader --dest "$dest" --url "$fallback" --socks5 "$SOCKS5_PROXY"
    return 0
  fi
  if downloader --dest "$dest" --url "$primary"; then
    return 0
  fi
  log_warn "Primary failed; trying fallback: $fallback"
  downloader --dest "$dest" --url "$fallback"
}

usage() {
  cat >&2 <<'USAGE'
Usage: china-ip-updater \
  --dest <file> \
  --v4 <url> --v4-fallback <url> \
  --v6 <url> --v6-fallback <url> \
  --set-v4 <name> --set-v6 <name> \
  [--socks5 <proxy>] [--table-name <name>]

Downloads IPv4/IPv6 lists, formats nft set definitions, writes atomically,
then applies them to the nft table.
USAGE
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --dest) DEST_FILE=$2; shift 2;;
      --v4) V4_URL_PRIMARY=$2; shift 2;;
      --v4-fallback) V4_URL_FALLBACK=$2; shift 2;;
      --v6) V6_URL_PRIMARY=$2; shift 2;;
      --v6-fallback) V6_URL_FALLBACK=$2; shift 2;;
      --set-v4) NFT_SET_V4=$2; shift 2;;
      --set-v6) NFT_SET_V6=$2; shift 2;;
      --socks5|--sock5) SOCKS5_PROXY=$2; shift 2;;
      --table-name) NFT_TABLE_NAME=$2; shift 2;;
      -h|--help) usage; exit 0;;
      --) shift; break;;
      *) log_error "Unknown option: $1"; usage; exit 2;;
    esac
  done

  # Validate required
  [[ -n "$DEST_FILE" ]] || { log_error "--dest is required"; usage; exit 2; }
  [[ -n "$V4_URL_PRIMARY" && -n "$V6_URL_PRIMARY" ]] || { log_error "--v4 and --v6 are required"; usage; exit 2; }
  [[ -n "$V4_URL_FALLBACK" && -n "$V6_URL_FALLBACK" ]] || { log_error "--v4-fallback and --v6-fallback are required"; usage; exit 2; }
  [[ -n "$NFT_SET_V4" && -n "$NFT_SET_V6" ]] || { log_error "--set-v4 and --set-v6 are required"; usage; exit 2; }
}

main() {
  parse_args "$@"
  log_info "Updating China IP lists into nft sets..."
  local dest_dir
  dest_dir=$(dirname "$DEST_FILE")
  mkdir -p "$dest_dir"

  TMP_V4=$(mktemp "$dest_dir/.chinaip.v4.XXXXXX")
  TMP_V6=$(mktemp "$dest_dir/.chinaip.v6.XXXXXX")
  TMP_OUT=$(mktemp "$dest_dir/.chinaip.out.XXXXXX")

  fetch_with_fallback "$V4_URL_PRIMARY" "$V4_URL_FALLBACK" "$TMP_V4"
  fetch_with_fallback "$V6_URL_PRIMARY" "$V6_URL_FALLBACK" "$TMP_V6"

  {
    echo "set $NFT_SET_V4 { type ipv4_addr; flags interval; elements = {"
    format_elements <"$TMP_V4"
    echo "} }"
    echo "set $NFT_SET_V6 { type ipv6_addr; flags interval; elements = {"
    format_elements <"$TMP_V6"
    echo "} }"
  } >"$TMP_OUT"

  chmod 0644 "$TMP_OUT"
  mv -f "$TMP_OUT" "$DEST_FILE"
  TMP_OUT=""

  log_info "Applying sets into table $NFT_TABLE_NAME..."
  nft flush set inet "$NFT_TABLE_NAME" "$NFT_SET_V4" || true
  nft flush set inet "$NFT_TABLE_NAME" "$NFT_SET_V6" || true
  (
    echo "table inet $NFT_TABLE_NAME {"
    cat "$DEST_FILE"
    echo "}"
  ) | nft -f -
  log_info "SUCCESS: China IP sets updated."
}

main "$@"

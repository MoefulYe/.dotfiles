#!/usr/bin/env bash
#
# ensure-exist.sh
#
# Ensure a target file exists; if missing, run an initializer command.
# Usage: ensure-exist <file-path> <initializer> [args...]
#
# Dependencies: bash, coreutils

set -eEuo pipefail

log_info()  { printf '[*] %s\n' "$*" >&2; }
log_warn()  { printf '[!] %s\n' "$*" >&2; }
log_error() { printf '[x] %s\n' "$*" >&2; }

usage() {
  cat >&2 <<'USAGE'
Usage: ensure-exist <file-path> [<initializer> [args...]]

Ensures <file-path> exists.
- If no arguments: error.
- If only <file-path>: check existence; error if missing.
- If <initializer> provided: run it with [args...] then recheck.
USAGE
}

if [[ ${1-} == "-h" || ${1-} == "--help" ]]; then
  usage; exit 0
fi

if [[ $# -eq 0 ]]; then
  log_error "Missing arguments"; usage; exit 2
fi

file_path=$1
shift || true

if [[ -z ${file_path} ]]; then
  log_error "<file-path> must not be empty"; exit 2
fi

if [[ -e "${file_path}" ]]; then
  log_info "'${file_path}' exists. Skipping initialization."
  exit 0
fi

# If no initializer provided, fail as requested
if [[ $# -eq 0 ]]; then
  log_error "'${file_path}' missing and no initializer provided"; exit 1
fi

cmd=$1
shift || true

log_warn "'${file_path}' not found. Running initializer: ${cmd} $*"
"${cmd}" "$@"

if [[ -e "${file_path}" ]]; then
  log_info "Initialization complete; '${file_path}' now exists."
  exit 0
fi

log_error "Initialization ran, but '${file_path}' still missing."
exit 1

#!/usr/bin/env bash
# Dependencies: cat mktemp mv rm rsync

set -eEuo pipefail
shopt -s failglob
umask 077

declare -r SCRIPT_NAME="${0##*/}"
declare -r EXIT_USAGE=2

TEMP_PATHS=()

cleanup() {
  local temp_path

  for temp_path in "${TEMP_PATHS[@]}"; do
    if [[ -n "${temp_path}" && -e "${temp_path}" ]]; then
      command rm -f "${temp_path}"
    fi
  done
}

trap cleanup EXIT INT TERM

usage() {
  cat <<EOF
Usage:
  ${SCRIPT_NAME} [--show-rsync-output] <SOURCE>
  ${SCRIPT_NAME} -h | --help

Copy a single rsync source into a local temporary file and print the final path.

Options:
  -v, --show-rsync-output  Print the wrapped rsync output instead of hiding it
  -h, --help               Show this help text and exit

Examples:
  ${SCRIPT_NAME} user@example.com:/path/to/file
  ${SCRIPT_NAME} --show-rsync-output user@example.com:/path/to/file
EOF
}

error() {
  local message="$1"

  printf '%s: %s\n' "${SCRIPT_NAME}" "${message}" >&2
}

usage_error() {
  local message="$1"

  error "${message}"
  printf '\n' >&2
  usage >&2
  exit "${EXIT_USAGE}"
}

check_dependencies() {
  local required_commands=(
    cat
    mktemp
    mv
    rm
    rsync
  )
  local missing_commands=()
  local command_name

  for command_name in "${required_commands[@]}"; do
    if ! command -v "${command_name}" >/dev/null 2>&1; then
      missing_commands+=("${command_name}")
    fi
  done

  if ((${#missing_commands[@]} > 0)); then
    error "missing required commands: ${missing_commands[*]}"
    exit 1
  fi
}

register_temp_path() {
  local temp_path="$1"

  TEMP_PATHS+=("${temp_path}")
}

make_temp_file() {
  local file_tag="$1"
  local base_dir="${TMPDIR:-/tmp}"
  local temp_path

  temp_path="$(mktemp "${base_dir%/}/${file_tag}.XXXXXX")"
  register_temp_path "${temp_path}"
  printf '%s\n' "${temp_path}"
}

main() {
  local show_rsync_output=false
  local source_path
  local final_path
  local partial_path
  local rsync_log_path
  local -a rsync_args=(
    -a
    -v
    -z
    -h
    -P
  )

  check_dependencies

  while (($# > 0)); do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -v|--show-rsync-output)
        show_rsync_output=true
        shift
        ;;
      --)
        shift
        break
        ;;
      -*)
        usage_error "unknown option: $1"
        ;;
      *)
        break
        ;;
    esac
  done

  if (($# != 1)); then
    usage_error "expected exactly one rsync source path"
  fi

  source_path="$1"
  final_path="$(make_temp_file "stash")"
  partial_path="$(make_temp_file "stash.partial")"
  rsync_log_path="$(make_temp_file "stash.log")"

  if [[ "${show_rsync_output}" == true ]]; then
    command rsync "${rsync_args[@]}" -- "${source_path}" "${partial_path}"
  else
    if ! command rsync "${rsync_args[@]}" -- "${source_path}" "${partial_path}" >"${rsync_log_path}" 2>&1; then
      command cat "${rsync_log_path}" >&2
      exit 1
    fi
  fi

  command mv -f "${partial_path}" "${final_path}"
  command rm -f "${rsync_log_path}"
  trap - EXIT INT TERM
  printf '%s\n' "${final_path}"
}

main "$@"

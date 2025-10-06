{ mihomoSocks5Port, pkgs,  ... }:
let
  url = "https://anti-ad.net/anti-ad-for-smartdns.conf";
in
pkgs.writeShellScript "anti-ad-downloader" ''
  #!${pkgs.bash}/bin/bash
  set -e
  set -o pipefail

  # --- Parameter Parsing ---
  USE_PROXY_LOGIC=false
  DEST_FILE=""

  # Use while and case for more standard parameter parsing
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --try-proxy)
        USE_PROXY_LOGIC=true
        shift # Move to the next parameter
        ;;
      --dest)
        # Check if --dest is followed by a value
        if [[ -n "$2" && "$2" != --* ]]; then
          DEST_FILE="$2"
          shift 2 # Move past --dest and its value
        else
          echo "[!] Error: --dest requires a file path argument." >&2
          exit 1
        fi
        ;;
      *)
        echo "[!] Error: Unknown option: $1" >&2
        exit 1
        ;;
    esac
  done

  # --- Parameter Validation ---
  if [[ -z "$DEST_FILE" ]]; then
    echo "[!] Error: The --dest parameter is required to specify the output file path." >&2
    exit 1
  fi

  readonly SOCKS5_PROXY=socks5://127.0.0.1:${builtins.toString mihomoSocks5Port}
  readonly CONNECT_TIMEOUT=10

  # --- Helper Function: Download File ---
  fetch_file() {
    local downloaded_data=""

    # Logic branch: decide behavior based on USE_PROXY_LOGIC
    if [[ "$USE_PROXY_LOGIC" == true ]]; then
      if [[ -n "$SOCKS5_PROXY" ]]; then
        echo "[*] (Proxy Mode) Attempting to fetch via SOCKS5 proxy ($SOCKS5_PROXY)..." >&2
        downloaded_data=$("${pkgs.curl}/bin/curl" -sSL --fail --connect-timeout $CONNECT_TIMEOUT -x "$SOCKS5_PROXY" "${url}" || true)

        if [[ -n "$downloaded_data" ]]; then
          echo "[*] Successfully fetched via proxy." >&2
          echo "$downloaded_data"
          return 0
        else
          echo "[!] Warning: Proxy download failed. Falling back to direct connection..." >&2
        fi
      else
        echo "[!] Warning: -try-proxy flag was given, but no socks5Proxy is configured. Proceeding directly." >&2
      fi
    fi

    # Old logic/fallback: direct connection
    echo "[*] Fetching directly" >&2
    downloaded_data=$("${pkgs.curl}/bin/curl" -sSL --fail --connect-timeout $CONNECT_TIMEOUT "${url}" || true)

    if [[ -n "$downloaded_data" ]]; then
      echo "[*] Successfully fetched directly." >&2
      echo "$downloaded_data"
    else
      echo "[!] Error: All download methods failed. Aborting." >&2
      exit 1
    fi
  }

  echo "[+] Starting anti-AD list download process..."
  readonly file_content=$(fetch_file)
  # --- Atomic Write to File ---
  TEMP_OUTPUT_FILE=$(${pkgs.mktemp}/bin/mktemp)
  trap "${pkgs.coreutils}/bin/rm -f \"$TEMP_OUTPUT_FILE\"" EXIT # Automatically clean up temp file on script exit
  echo "[*] Processing content by replacing '#' with '0.0.0.0' and writing to temporary file..." >&2
  # Modify the content: replace '#' with '0.0.0.0' using sed and write to the temp file
  echo "$file_content" | ${pkgs.gnused}/bin/sed 's/#/0.0.0.0/g' > "$TEMP_OUTPUT_FILE"
  echo "[*] Atomically replacing old list file..." >&2
  ${pkgs.coreutils}/bin/mv "$TEMP_OUTPUT_FILE" "$DEST_FILE"
  echo "[+] Success! anti-AD list updated at $DEST_FILE" >&2
''
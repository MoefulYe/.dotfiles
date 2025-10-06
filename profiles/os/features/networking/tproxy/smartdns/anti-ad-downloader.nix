{ mihomoSocks5Port, pkgs,  ... }: 
let 
  url = "https://anti-ad.net/anti-ad-for-smartdns.conf";
in
pkgs.writeShellScript "anti-ad-downloader" ''
  #!${pkgs.bash}/bi  #!${pkgs.bash}/bin/bash
  set -e
  set -o pipefail

  # --- 参数解析 ---
  USE_PROXY_LOGIC=false
  DEST_FILE=""

  # 使用 while 和 case 进行更标准的参数解析
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --try-proxy)
        USE_PROXY_LOGIC=true
        shift # 移向下一个参数
        ;;
      --dest)
        # 检查 --dest 后面是否跟了值
        if [[ -n "$2" && "$2" != --* ]]; then
          DEST_FILE="$2"
          shift 2 # 移过 --dest 和它的值
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

  # --- 参数验证 ---
  if [[ -z "$DEST_FILE" ]]; then
    echo "[!] Error: The --dest parameter is required to specify the output file path." >&2
    exit 1
  fi
  
  readonly SOCKS5_PROXY=socks5://127.0.0.1:${builtins.toString mihomoSocks5Port}
  readonly CONNECT_TIMEOUT=10

  # --- 辅助函数：下载文件 ---
  fetch_file() {
    local downloaded_data=""
    
    # 逻辑分支：根据 USE_PROXY_LOGIC 决定行为
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

    # 旧逻辑/回退逻辑：直接连接
    echo "[*] Fetching directly from $PRIMARY_URL..." >&2
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
  # --- 原子化写入文件 ---
  TEMP_OUTPUT_FILE=$(mktemp)
  trap "rm -f \"$TEMP_OUTPUT_FILE\"" EXIT # 脚本退出时自动清理临时文件
  echo "[*] Writing content to temporary file..." >&2
  echo "$file_content" > "$TEMP_OUTPUT_FILE"
  echo "[*] Atomically replacing old list file..." >&2
  mv "$TEMP_OUTPUT_FILE" "$DEST_FILE"
  echo "[+] Success! anti-AD list updated at $DEST_FILE" >&2
''

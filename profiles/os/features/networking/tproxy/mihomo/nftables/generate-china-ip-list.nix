{ pkgs, cfg, mihomoSocks5Port, ... }: 
let 
  chinaIpSources = rec {
    primary = {
      v4 = "https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt";
      v6 = "https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute_v6.txt";
    };
    fallback = {
      v4 = "https://hub.gitmirror.com/${primary.v4}";
      v6 = "https://hub.gitmirror.com/${primary.v6}";
    };
  };
in pkgs.writeShellScript "generate-china-ip-list" ''
  #!${pkgs.bash}/bin/bash
  set -e
  set -o pipefail

  # --- 参数解析 ---
  USE_PROXY_LOGIC=false
  # 遍历所有传入的参数
  for arg in "$@"; do
    if [[ "$arg" == "--try-proxy" ]]; then
      USE_PROXY_LOGIC=true
      break # 找到标志后即可退出循环
    fi
  done

  # --- 配置区 ---
  URL_IPV4_PRIMARY="${chinaIpSources.primary.v4}"
  URL_IPV6_PRIMARY="${chinaIpSources.primary.v6}"
  URL_IPV4_FALLBACK="${chinaIpSources.fallback.v4}"
  URL_IPV6_FALLBACK="${chinaIpSources.fallback.v6}"

  SOCKS5_PROXY="socks5://127.0.0.1:${builtins.toString mihomoSocks5Port}" 
  CONNECT_TIMEOUT=10

  DIR="/var/lib/${cfg.chinaIpListDirname}"
  NFT_SET_NAME_V4="${cfg.chinaIpV4Set}"
  NFT_SET_NAME_V6="${cfg.chinaIpV6Set}"
  OUTPUT_NFT_FILE="${cfg.chinaIPListBasename}"

  # --- 辅助函数：获取并格式化 CIDR 列表 ---
  fetch_and_format_cidrs() {
    local primary_url="$1"
    local fallback_url="$2"
    local downloaded_data=""

    # 逻辑分支：根据 USE_PROXY_LOGIC 决定行为
    if [[ "$USE_PROXY_LOGIC" == true ]]; then
      # ======== 新逻辑：代理优先，失败回退 ========
      if [[ -n "$SOCKS5_PROXY" ]]; then
        echo "[*] (Proxy Mode) Attempting to fetch via SOCKS5 proxy ($SOCKS5_PROXY) from: $primary_url" >&2
        downloaded_data=$("${pkgs.curl}/bin/curl" -sSL --fail --connect-timeout $CONNECT_TIMEOUT -x "$SOCKS5_PROXY" "$primary_url" || true)
        
        if [[ -n "$downloaded_data" ]]; then
          echo "[*] Successfully fetched via proxy." >&2
          echo "$downloaded_data" | "${pkgs.gnused}/bin/sed" '/^$/d' | "${pkgs.gawk}/bin/awk" '{printf "        %s,\n", $0}'
          return 0
        else
          echo "[!] Warning: Proxy download failed. Falling back to mirror..." >&2
        fi
      else
        echo "[!] Warning: --try-proxy flag was given, but no socks5Proxy is configured. Proceeding to mirror." >&2
      fi
    else
      echo "[*] (Standard Mode) Bypassing proxy logic." >&2
    fi

    # ======== 旧逻辑/回退逻辑：直接从镜像下载 ========
    echo "[*] Fetching IP list from mirror: $fallback_url" >&2
    downloaded_data=$("${pkgs.curl}/bin/curl" -sSL --fail --connect-timeout $CONNECT_TIMEOUT "$fallback_url" || true)

    if [[ -n "$downloaded_data" ]]; then
      echo "[*] Successfully fetched from mirror." >&2
      echo "$downloaded_data" | "${pkgs.gnused}/bin/sed" '/^$/d' | "${pkgs.gawk}/bin/awk" '{printf "        %s,\n", $0}'
    else
      echo "[!] Error: All download methods failed. Aborting." >&2
      exit 1
    fi
  }

  echo "[+] Starting China IP list generation process..." >&2
  if [[ "$USE_PROXY_LOGIC" == true ]]; then
      echo "[+] Mode: Proxy enabled (-try-proxy)." >&2
  else
      echo "[+] Mode: Standard mirror only." >&2
  fi

  # --- 核心操作 (保持不变) ---
  IPV4_CIDRS=$(fetch_and_format_cidrs "$URL_IPV4_PRIMARY" "$URL_IPV4_FALLBACK")
  IPV4_CIDRS=$(echo "$IPV4_CIDRS" | "${pkgs.gnused}/bin/sed" '$s/, *$//')

  IPV6_CIDRS=$(fetch_and_format_cidrs "$URL_IPV6_PRIMARY" "$URL_IPV6_FALLBACK")
  IPV6_CIDRS=$(echo "$IPV6_CIDRS" | "${pkgs.gnused}/bin/sed" '$s/, *$//')
  
  # --- 文件生成部分 (保持不变) ---
  TEMP_OUTPUT_FILE="$(mktemp "$DIR/temp-XXXXXX.nft")"
  trap "rm -f \"$TEMP_OUTPUT_FILE\"" EXIT

  echo "[*] Formatting final nftables configuration file..." >&2
  cat > "$TEMP_OUTPUT_FILE" << EOF
  # ... (文件内容模板部分省略，与之前版本相同) ...
  set $NFT_SET_NAME_V4 { type ipv4_addr; flags interval; elements = {
  $IPV4_CIDRS
  } }
  set $NFT_SET_NAME_V6 { type ipv6_addr; flags interval; elements = {
  $IPV6_CIDRS
  } }
  EOF
  
  echo "[*] Atomically replacing old IP list file..." >&2
  mv "$TEMP_OUTPUT_FILE" "$DIR/$OUTPUT_NFT_FILE"
  
  echo -e "\n[+] Success! Nftables set definitions written to '$DIR/$OUTPUT_NFT_FILE'" >&2
''

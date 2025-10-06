{ generateChinaIPList, table, writeShellScript, nftables, bash, cfg, gnugrep, ... }: writeShellScript "mihomo-nftables-ctl" ''
  #!${bash}/bin/bash
  set -euo pipefail # 启用所有健壮性选项

  # --- Injected Nix Variables ---
  # Nix 会自动将这些变量的值替换进来，生成一个静态的脚本
  readonly NFT_CMD="${nftables}/sbin/nft"
  readonly CHINA_IP_LIST_FILE="/var/lib/${cfg.chinaIpListDirname}/${cfg.chinaIPListBasename}"

  # --- Main Logic ---
  case "''${1:-}" in
    up)
      echo "INFO: Applying Mihomo TProxy nftables rules..."

      if [ ! -f "$CHINA_IP_LIST_FILE" ]; then
        echo "NOTICE: China IP list file not found. Triggering initial download..." >&2
        
        if ! ${generateChinaIPList}; then
          echo "ERROR: The initial download service failed to run." >&2
          exit 1
        fi
        
        if [ ! -f "$CHINA_IP_LIST_FILE" ]; then
          echo "ERROR: Initial download service ran, but the IP list file is still missing." >&2
          exit 1
        fi
        echo "INFO: Initial download complete."
      else
        echo "INFO: China IP list file already exists. Skipping download."
      fi
      
      if ! $NFT_CMD -f ${table}; then
        echo "ERROR: Failed to apply nftables ruleset." >&2
        exit 1
      fi

      echo "SUCCESS: Mihomo TProxy nftables rules applied successfully."
      ;;

    down)
      echo "INFO: Deleting Mihomo TProxy nftables table..."
      
      if $NFT_CMD list tables | ${gnugrep}/bin/grep -q 'mihomo-tproxy'; then
        if ! $NFT_CMD delete table inet mihomo-tproxy; then
          echo "ERROR: Failed to delete nftables table 'inet mihomo-tproxy'." >&2
          exit 1
        fi
        echo "SUCCESS: Mihomo TProxy table deleted successfully."
      else
        echo "INFO: Mihomo TProxy table does not exist, nothing to do."
      fi
      ;;

    *)
      echo "Usage: $0 {up|down}" >&2
      exit 1
      ;;
  esac
''
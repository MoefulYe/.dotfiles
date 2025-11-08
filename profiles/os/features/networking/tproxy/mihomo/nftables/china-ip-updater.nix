{
  writeShellScript,
  downloadChinaIPList,
  pkgs,
  cfg,
  mihomoCfg,
  ...
}:
writeShellScript "china-ip-updater" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail
  INPUT_FILE="/var/lib/${cfg.chinaIpListDirname}/${cfg.chinaIPListBasename}"
  ${downloadChinaIPList} \
    --dir "/var/lib/${cfg.chinaIpListDirname}" \
    --out-name "${cfg.chinaIPListBasename}" \
    --set-v4 "${cfg.chinaIpV4Set}" \
    --set-v6 "${cfg.chinaIpV6Set}" \
    --socks5 "socks5://127.0.0.1:${builtins.toString mihomoCfg.socks5Port}"
  if [ ! -f "$INPUT_FILE" ]; then
      echo "Error: Input file not found at '$INPUT_FILE'" >&2
      exit 1
  fi
  ${pkgs.nftables}/sbin/nft flush set inet mihomo-tproxy ${cfg.chinaIpV4Set}
  ${pkgs.nftables}/sbin/nft flush set inet mihomo-tproxy ${cfg.chinaIpV6Set}
  echo "Info: starting update nftables china ip list set" >&2
  (
    echo "table inet mihomo-tproxy {"
    ${pkgs.coreutils}/bin/cat "$INPUT_FILE"
    echo "}"
  ) | ${pkgs.nftables}/sbin/nft -f -
  echo "SUCCESS: china ip list updated successfully." >&2
''

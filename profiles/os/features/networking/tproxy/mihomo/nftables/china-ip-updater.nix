{
  writeShellApplication,
  coreutils,
  nftables,
  downloadChinaIPList,
  pkgs,
  cfg,
  mihomoCfg,
  ...
}:
writeShellApplication {
  name = "china-ip-updater";
  runtimeInputs = [ coreutils nftables downloadChinaIPList pkgs.bash ];
  text = ''
    exec ${pkgs.bash}/bin/bash ${./china-ip-updater.sh} \
      --dir "/var/lib/${cfg.chinaIpListDirname}" \
      --out-name "${cfg.chinaIPListBasename}" \
      --set-v4 "${cfg.chinaIpV4Set}" \
      --set-v6 "${cfg.chinaIpV6Set}" \
      --table-name "mihomo-tproxy" \
      --socks5 "socks5://127.0.0.1:${builtins.toString mihomoCfg.socks5Port}"
  '';
}

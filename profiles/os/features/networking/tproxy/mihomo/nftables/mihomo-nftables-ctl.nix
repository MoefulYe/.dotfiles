{
  writeShellApplication,
  coreutils,
  gnugrep,
  nftables,
  downloadChinaIPList,
  ...
}:
writeShellApplication {
  name = "mihomo-nftables-ctl";
  runtimeInputs = [ coreutils gnugrep nftables downloadChinaIPList ];
  text = builtins.readFile ./mihomo-nftables-ctl.sh;
}

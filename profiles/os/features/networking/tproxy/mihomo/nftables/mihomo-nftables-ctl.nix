{
  writeShellApplication,
  nftables,
  coreutils,
  gnugrep,
  ensureExist,
  chinaIpUpdater,
  ...
}:
writeShellApplication {
  name = "mihomo-nftables-ctl";
  runtimeInputs = [ nftables coreutils gnugrep ensureExist chinaIpUpdater ];
  text = builtins.readFile ./mihomo-nftables-ctl.sh;
}

{
  writeShellApplication,
  coreutils,
  gnugrep,
  nftables,
  ...
}:
writeShellApplication {
  name = "mihomo-nftables-ctl";
  runtimeInputs = [
    coreutils
    gnugrep
    nftables
  ];
  text = builtins.readFile ./mihomo-nftables-ctl.sh;
}

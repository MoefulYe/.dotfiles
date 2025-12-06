{
  writeShellApplication,
  coreutils,
  gnugrep,
  nftables,
  gawk,
  ...
}:
writeShellApplication {
  name = "mihomo-nftables-ctl";
  runtimeInputs = [
    coreutils
    gnugrep
    nftables
    gawk
  ];
  text = builtins.readFile ./mihomo-nftables-ctl.sh;
}

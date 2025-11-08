{ writeShellApplication, downloader, coreutils, gawk, nftables, ... }:
writeShellApplication {
  name = "china-ip-updater";
  runtimeInputs = [ downloader coreutils gawk nftables ];
  text = builtins.readFile ./china-ip-updater.sh;
}

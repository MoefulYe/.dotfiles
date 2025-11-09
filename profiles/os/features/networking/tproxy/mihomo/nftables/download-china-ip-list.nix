{
  writeShellApplication,
  coreutils,
  curl,
  gnused,
  gawk,
  downloader,
  ...
}:
writeShellApplication {
  name = "download-china-ip-list";
  runtimeInputs = [
    coreutils
    curl
    gnused
    gawk
    downloader
  ];
  text = builtins.readFile ./download-china-ip-list.sh;
}

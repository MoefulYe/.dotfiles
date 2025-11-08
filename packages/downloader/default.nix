{
  writeShellApplication,
  coreutils,
  curl,
  ...
}:
writeShellApplication {
  name = "downloader";
  runtimeInputs = [
    coreutils
    curl
  ];
  text = builtins.readFile ./downloader.sh;
}

{
  writeShellApplication,
  coreutils,
  curl,
  gnused,
  gawk,
  ...
}:
writeShellApplication {
  name = "download-china-ip-list";
  runtimeInputs = [ coreutils curl gnused gawk ];
  text = builtins.readFile ./download-china-ip-list.sh;
}


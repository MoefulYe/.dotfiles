{
  writeShellApplication,
  coreutils,
  bash,
  ...
}:
writeShellApplication {
  name = "ensure-exist";
  runtimeInputs = [
    coreutils
    bash
  ];
  text = builtins.readFile ./ensure-exist.sh;
}

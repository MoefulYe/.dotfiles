{
  outputs,
  ...
}:
let
  overlays = (builtins.attrValues outputs.overlays);
in
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
    inherit overlays;
  };
}

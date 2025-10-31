{
  pkgs,
  helpers,
  inventory,
  lib,
  ...
}:
let
  mkCatAuthorizedKeys = helpers.mkCatAuthorizedKeys;
in
{
  users.users = {
    ashenye = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = mkCatAuthorizedKeys {
        inherit inventory lib;
      };
      createHome = true;
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "input"
        "docker"
        "wireshark"
        "ubridge"
        "podman"
        "libvirtd"
        "libvirt"
        "kvm"
      ];
      shell = pkgs.zsh;
    };
    lab-guest = {
      isNormalUser = true;
      createHome = true;
    };
  };
}

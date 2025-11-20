{ pkgs, ... }:
{
  users.users = {
    ashenye = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "input"
        "docker"
        "libvirt"
        "wireshark"
        "ubridge"
      ];
      shell = pkgs.zsh;
    };
  };
}

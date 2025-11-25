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
        "aria2"
      ];
      shell = pkgs.zsh;
    };
  };
}

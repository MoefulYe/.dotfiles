{
  pkgs,
  ...
}:
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
        "wireshark"
        "ubridge"
        "podman"
        "libvirtd"
        "libvirt"
        "kvm"
        "aria2"
      ];
      shell = pkgs.zsh;
    };
    lab-guest = {
      isNormalUser = true;
      createHome = true;
    };
  };
}

{ pkgs, ... }: {
  users.users = {
    ashenye = {
      isNormalUser = true;
      # openssh.authorizedKeys.keys = [
      # ];
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

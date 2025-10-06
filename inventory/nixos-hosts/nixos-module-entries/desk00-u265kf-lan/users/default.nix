{ pkgs, ... }: {
  osProfiles.common.users = {
    ashenye = {
      osConfig = {
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
          "podman"
        ];
      	shell = pkgs.zsh;
      };
      hmEntry = ./ashenye.nix;
      userInfo = {
        email = "luren145@gmail.com";
      };
    };
    lab-guest = {
      osConfig = {
        isNormalUser = true;
        createHome = true;
      };
    };
  };
  osProfiles.common.hostInfo.priUser = "ashenye";
}

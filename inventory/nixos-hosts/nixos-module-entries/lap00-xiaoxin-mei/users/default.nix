{
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
        ];
      };
      hmEntry = ./ashenye.nix;
      userInfo = {
        email = "luren145@gmail.com";
      };
    };
  };
  osProfiles.common.hostInfo.priUser = "ashenye";
}

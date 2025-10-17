{
  users.users = {
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
    };
  };
  osProfiles.common.priUser = "ashenye";
}

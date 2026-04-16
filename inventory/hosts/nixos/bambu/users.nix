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

{ pkgs, ... }:
{
  users.users = {
    ashenye = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [
        "wheel"
        "aria2"
      ];
      shell = pkgs.zsh;
    };
  };
}

{ pkgs, ... }:
{
  users.users = {
    ashenye = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [
        "wheel"
      ];
      shell = pkgs.zsh;
    };
  };
}

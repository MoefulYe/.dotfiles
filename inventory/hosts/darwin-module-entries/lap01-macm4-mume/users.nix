{ pkgs, ... }:
{
  users.users."ashenye" = {
    shell = pkgs.zsh;
    home = "/Users/ashenye";
  };
}

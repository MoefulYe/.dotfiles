{ config, ... }:
let
  inherit (config.userProfiles) username email;
in
{
  programs.git = {
    enable = true;
    userName = username;
    userEmail = email;
  };
}

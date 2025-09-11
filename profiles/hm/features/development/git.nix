{ config, ... }:
{
  programs.git = {
    enable = true;
    userName = config.home.username;
    userEmail = config.userInfo.email;
  };
}

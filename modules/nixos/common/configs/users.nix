{
  inputs,
  outputs,
  config,
  pkgs,
  ...
}:
let
  basicProfiles = config.systemProfiles.basic;
  defaultUserShell = config.systemProfiles.defaultApps.shell.pkg;
  myusername = basicProfiles.me.username;
  myemail = basicProfiles.me.email;
in
{
  programs.zsh.enable = true;
  users = {
    inherit defaultUserShell;
    users = {
      ${myusername} = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          #todo
        ];
        home = "/home/${myusername}";
        extraGroups = [
          "wheel"
          "video"
          "audio"
          "input"
          "networkmanager"
          "docker"
          "libvirt"
        ];
      };
    };
  };
}

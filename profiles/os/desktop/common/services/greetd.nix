{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.greetd = {
    enable = true;
    settings =
      let
        inherit (config.osProfiles.hostInfo) priUser;
      in
      {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
          user = lib.mkIf (priUser != null) priUser;
        };
        initial_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
          user = lib.mkIf (priUser != null) priUser;
        };
      };
  };
}

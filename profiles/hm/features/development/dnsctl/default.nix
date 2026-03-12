{
  lib,
  config,
  pkgs,
  paths,
  ...
}:
let
  cfg = config.hmProfiles.dev;
in
{
  config = lib.mkIf cfg.daily {
    home.packages = with pkgs; [
      dnsctl
    ];
    sops.secrets = {
      CF_PIPPAYE_ZONE_EDIT_TOKEN = {
        mode = "0400";
        sopsFile = "${paths.secrets}/api-tokens.yaml";
      };
    };
  };
}

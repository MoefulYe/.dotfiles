{ config, ... }:
let
  cfg = config.osProfiles.features.tproxy.tproxyBypassUser;
  inherit (cfg) name uid;
in
{
  users = {
    users."${name}" = {
      group = name;
      isNormalUser = true;
      inherit uid;
    };
    groups."${name}" = { };
  };
}

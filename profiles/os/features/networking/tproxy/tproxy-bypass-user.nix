{ config, lib, ... }:
let
  bypassCfg = config.osProfiles.features.tproxy.tproxyBypass;
  mihomoCfg = config.osProfiles.features.tproxy.mihomo;
  sliceAttr = lib.removeSuffix ".slice" bypassCfg.sliceName;
in
{
  users = {
    users."${mihomoCfg.user}" = {
      group = mihomoCfg.user;
      isSystemUser = true;
      uid = mihomoCfg.uid;
    };
    groups."${mihomoCfg.user}" = { };
  };

  systemd.slices."${sliceAttr}" = { };
}

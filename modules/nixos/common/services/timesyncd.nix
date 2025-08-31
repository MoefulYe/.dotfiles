{ config, ... }:
with config.systemProfiles.features.timesyncd;
{
  services.timesyncd = {
    inherit enable servers;
  };
}

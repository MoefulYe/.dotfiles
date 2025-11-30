{ isLinux, ... }:
{
  nix.gc =
    if isLinux then
      {
        automatic = true;
        persistent = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
        randomizedDelaySec = "1h";
      }
    else
      {
        automatic = true;
      };
}

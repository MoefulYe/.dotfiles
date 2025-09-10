{
  # TODO improve
  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
    randomizedDelaySec = "1h";
  };
}
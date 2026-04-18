{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  users.users.jellyfin.extraGroups = [
    "render"
    "video"
  ];

  systemd.services.jellyfin.environment = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  environment.systemPackages = with pkgs; [
    libva-utils
  ];
}

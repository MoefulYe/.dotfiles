{
  pkgs,
  ...
}:
{
  programs.mpv = {
    enable = true;
    package = pkgs.mpv-unwrapped.wrapper {
      mpv = pkgs.mpv-unwrapped.override {
        vapoursynthSupport = true;
        vapoursynth = (pkgs.vapoursynth.withPlugins [ pkgs.vapoursynth-mvtools ]);
      };
      scripts = with pkgs.mpvScripts; [
        mpris
        thumbfast
        mpv-notify-send
        uosc
      ];
    };
  };
  home.packages = with pkgs; [
    yt-dlp
  ];
  xdg.configFile = {
    "mpv/mpv.conf".source = ./mpv.conf;
    "mpv/vs" = {
      source = ./vs;
      recursive = true;
    };
    "mpv/profiles.conf".source = ./profiles.conf;
    "mpv/scripts" = {
      source = ./scripts;
      recursive = true;
    };
    "mpv/script-opts" = {
      source = ./script-opts;
      recursive = true;
    };
    "mpv/input.conf".source = ./input.conf;
    "mpv/shaders/retro-crt/profiles.conf".text = import ./shaders/retro-crt/profiles.nix {
      retro-crt = import ./shaders/retro-crt/drv.nix { inherit pkgs; };
    };
    "mpv/shaders/anime4k/profiles.conf".text = import ./shaders/anime4k/profiles.nix {
      anime4k = pkgs.anime4k;
    };
  };
}

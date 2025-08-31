{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkOption types;
in
with pkgs;
{
  options.systemProfiles.defaultApps = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          pkg = mkOption {
            type = types.nullOr types.package;
          };
          entry = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "xdg entry for this application";
          };
          binname = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "name of the binary to be used in shell";
          };
        };
      }
    );
  };
  config.systemProfiles.defaultApps = {
    terminal = mkDefault {
      pkg = kitty;
      entry = "kitty.desktop";
      binname = "kitty";
    };
    shell = mkDefault {
      pkg = zsh;
      entry = "zsh.desktop";
      binname = "zsh";
    };
    editor = mkDefault {
      pkg = neovim;
      entry = "nvim.desktop";
      binname = "nvim";
    };
    browser = mkDefault {
      entry = "zen-browser.desktop";
      binname = "zen";
    };
    file-manager = mkDefault {
      pkg = yazi;
      entry = "yazi.desktop";
      binname = "yazi";
    };
    img-viewer = mkDefault {
      pkg = imv;
      entry = "imv.desktop";
      binname = "imv";
    };
    pdf-viewer = mkDefault {
      pkg = zathura;
      entry = "org.pwmt.zathura.desktop";
      binname = "zathura";
    };
    video-player = mkDefault {
      pkg = mpv;
      entry = "mpv.desktop";
      binname = "mpv";
    };
    music-player = mkDefault {
      pkg = mpd;
      entry = "mpd.desktop";
    };
  };
}

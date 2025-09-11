{
  pkgs,
  lib,
  config,
  ...
}:
let
  preferences = with pkgs; {
    terminal = {
      pkg = kitty;
      entry = "kitty.desktop";
      binname = "kitty";
    };
    shell = {
      pkg = zsh;
      entry = "zsh.desktop";
      binname = "zsh";
    };
    editor = {
      pkg = neovim;
      entry = "nvim.desktop";
      binname = "nvim";
    };
    browser = {
      entry = "zen-browser.desktop";
      binname = "zen";
    };
    file-manager = {
      pkg = yazi;
      entry = "yazi.desktop";
      binname = "yazi";
    };
    img-viewer = {
      pkg = imv;
      entry = "imv.desktop";
      binname = "imv";
    };
    pdf-viewer = {
      pkg = zathura;
      entry = "org.pwmt.zathura.desktop";
      binname = "zathura";
    };
    video-player = {
      pkg = mpv;
      entry = "mpv.desktop";
      binname = "mpv";
    };
    # music-player = {
    #   pkg = mpd;
    #   entry = "mpd.desktop";
    # };
  };
in
{
  home.sessionVariables = {
    EDITOR = preferences.editor.binname;
    VISUAL = preferences.editor.binname;
    BROWSER = preferences.browser.binname;
    TERMINAL = preferences.terminal.binname;
  };
}

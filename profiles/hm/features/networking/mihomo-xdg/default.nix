{ pkgs, ... }:
{
  xdg.desktopEntries = {
    mihomo-webui = {
      name = "Mihomo Web UI";
      genericName = "Mihomo Dashboard";
      comment = "Open Mihomo Web UI in default browser";
      type = "Application";
      # Use default browser via xdg-open. Adjust URL if you host a local external-ui.
      exec = "${pkgs.xdg-utils}/bin/xdg-open \"http://localhost:9090\"";
      terminal = false;
      # Uses a common theme icon. Replace with a custom icon name or absolute path if desired.
      icon = "${./icon.png}";
    };
  };
}

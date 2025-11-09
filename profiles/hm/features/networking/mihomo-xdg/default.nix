{ pkgs, ... }:
{
  xdg.desktopEntries = {
    clash-webui = {
      name = "Clash Web UI";
      genericName = "Clash/Mihomo Dashboard";
      comment = "Open Clash (Mihomo) Web UI in default browser";
      type = "Application";
      # Use default browser via xdg-open. Adjust URL if you host a local external-ui.
      exec = "${pkgs.xdg-utils}/bin/xdg-open \"https://metacubex.github.io/metacubexd/#/?hostname=127.0.0.1&port=9090\"";
      terminal = false;
      # Uses a common theme icon. Replace with a custom icon name or absolute path if desired.
      icon = "${./icon.png}";
    };
  };
}

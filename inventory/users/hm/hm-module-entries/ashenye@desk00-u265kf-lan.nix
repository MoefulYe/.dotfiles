{ paths, inputs, ... }:
let
  inherit (paths) hmRoles;
in
{
  imports = [
    inputs.vscode-server.homeModules.default
  ];
  services.vscode-server.enable = true;
}

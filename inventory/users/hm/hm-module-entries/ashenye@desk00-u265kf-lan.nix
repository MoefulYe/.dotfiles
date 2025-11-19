{ paths, inputs, ... }:
let
  inherit (paths) hmRoles;
in
{
  imports = [
    "${hmRoles}/daily"
    inputs.vscode-server.homeModules.default
  ];
  services.vscode-server.enable = true;
}

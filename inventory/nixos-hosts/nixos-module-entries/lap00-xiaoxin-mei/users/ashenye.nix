{ inventory, paths, ... }:
let
  inherit (paths) hmRoles;
in
{
  imports = [
    "${hmRoles}/daily"
    inventory.externalHosts.zju-lab-serv-w3090.sshConfig
  ];
}

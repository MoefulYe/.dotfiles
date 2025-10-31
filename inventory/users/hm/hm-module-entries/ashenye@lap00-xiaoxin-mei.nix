{ inventory, paths, ... }:
let
  inherit (paths) hmRoles;
in
{
  imports = [
    "${hmRoles}/daily"
    inventory.externalHosts.zju-lab-serv-w3090.sshConfig
    inventory.externalHosts.zju-lab-serv-zhang.sshConfig
    inventory.externalHosts.zju-lab-serv-yu-sg.sshConfig
  ];
}

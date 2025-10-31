{ inventory, paths, ... }:
let
  inherit (paths) hmRoles;
in
{
  imports = [
    "${hmRoles}/daily"
    # "${hmProfiles}/features/gaming/shadps4.nix"
    inventory.hosts.external.zju-lab-serv-w3090.sshConfig
    inventory.hosts.external.zju-lab-serv-zhang.sshConfig
    inventory.hosts.external.zju-lab-serv-yu-sg.sshConfig
  ];
}

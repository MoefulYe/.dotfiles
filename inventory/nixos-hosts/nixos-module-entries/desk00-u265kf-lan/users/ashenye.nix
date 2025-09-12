{ inventory, paths, ... }:
let
  inherit (paths) hmRoles hmProfiles;
in
{
  imports = [
    "${hmRoles}/daily"
    "${hmProfiles}/features/gaming/shadps4.nix"
    inventory.externalHosts.zju-lab-serv-w3090.sshConfig
  ];
}

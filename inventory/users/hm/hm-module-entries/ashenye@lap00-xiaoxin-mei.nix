{ paths, ... }:
let
  inherit (paths) hmRoles;
in
{
  imports = [
    "${hmRoles}/daily"
  ];
}

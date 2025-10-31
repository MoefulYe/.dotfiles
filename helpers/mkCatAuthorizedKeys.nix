{
  inventory,
  lib,
}:
let
  hasTag = import ./hasTag.nix;
in
inventory.users
|> lib.filterAttrs (
  name: props:
  hasTag {
    tags = props.userInfo.tags;
    tagToCheck = "cat";
  }
)
|> lib.mapAttrsToList (username: user: user.userInfo.sshPubkey)

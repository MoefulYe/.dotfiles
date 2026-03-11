{
  lib,
  inventory,
  userInfo,
  ...
}:
let
  inherit (userInfo) userid;
  topology = import ./topology.nix inventory;
  allowIn =
    topology
    |> lib.concatMap ({ froms, tos, ... }: lib.optionals (lib.elem userid tos) froms)
    |> lib.unique;
  allowOut =
    topology
    |> lib.concatMap ({ froms, tos, ... }: lib.optionals (lib.elem userid froms) tos)
    |> lib.unique;
in
{
  imports =
    allowOut
    |> lib.map (
      toUserId:
      if lib.isString toUserId then
        inventory.users.${toUserId}.sshConfig
      else if lib.isAttrs toUserId && lib.hasAttr "sshConfig" toUserId then
        toUserId.sshConfig
      else
        throw "Invalid sshConfig for userId"
    );
  home.file.".ssh/.authorized_keys" =
    let
      authorizedKeysContent =
        allowIn
        |> lib.concatMapStringsSep "\n" (
          userId:
          if lib.isString userId then
            inventory.users.${userId}.sshPubKey
          else if lib.isAttrs userId && lib.hasAttr "sshPubKey" userId then
            userId.sshPubKey
          else
            throw "Invalid sshPubKey for userId"
        );
    in
    lib.mkIf (authorizedKeysContent != "") {
      text = authorizedKeysContent;
      onChange = ''
        cat ~/.ssh/.authorized_keys > ~/.ssh/authorized_keys
        rm ~/.ssh/.authorized_keys
        chmod 600 ~/.ssh/authorized_keys
      '';
      force = true;
    };
}

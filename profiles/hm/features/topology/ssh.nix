{
  lib,
  inventory,
  userInfo,
  ...
}:
let
  inherit (userInfo) userid;
  typeHandlers = {
    edge =
      { from, to, ... }:
      {
        allowIn = lib.optional (to == userid) from;
        allowOut = lib.optional (from == userid) to;
      };
    "cert-prod" =
      { froms, tos, ... }:
      {
        allowIn = lib.optionals (lib.elem userid tos) froms;
        allowOut = lib.optionals (lib.elem userid froms) tos;
      };
    "complete-graph" =
      { nodes, ... }:
      let
        inGraph = lib.elem userid nodes;
        peers = lib.remove userid nodes;
      in
      if inGraph then
        {
          allowIn = peers;
          allowOut = peers;
        }
      else
        {
          allowIn = [ ];
          allowOut = [ ];
        };
    ego =
      { nodes, ... }:
      {
        allowIn = lib.optionals (lib.elem userid nodes) [ userid ];
        allowOut = lib.optionals (lib.elem userid nodes) [ userid ];
      };
  };
  handleEntry =
    entry:
    let
      type = entry.type or "edge";
    in
    if builtins.hasAttr type typeHandlers then
      typeHandlers.${type} entry
    else
      throw "Unknown ssh topology entry type: ${type}";
  resolved = inventory.topology.ssh |> lib.map handleEntry;
  allowIn = resolved |> lib.concatMap (r: r.allowIn) |> lib.unique;
  allowOut = resolved |> lib.concatMap (r: r.allowOut) |> lib.unique;
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

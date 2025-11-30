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
  imports = allowOut |> lib.map (toUserId: inventory.users.${toUserId}.sshConfig);
  home.file.".ssh/.authorized_keys" =
    let
      authorizedKeysContent =
        allowIn |> lib.concatMapStringsSep "\n" (userId: inventory.users.${userId}.sshPubKey);
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

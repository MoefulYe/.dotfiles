{
  lib,
  inventory,
  userInfo,
  pkgs,
  ...
}:
let
  sshGraph = inventory.topology.ssh;
  inherit (userInfo) userid;
  # 所有允许连接到该用户的来源列表
  allowIn = sshGraph |> lib.filter ({ from, to }: to == userid) |> lib.map (entry: entry.from);
  # 所有该用户允许连接到的目标列表
  allowOut = sshGraph |> lib.filter ({ from, to }: from == userid) |> lib.map (entry: entry.to);
in
{
  imports = allowOut |> lib.map (toUserId: inventory.users.${toUserId}.sshConfig);
  home.file.".ssh/.authorized_keys" =
    let
      authorizedKeysContent = lib.concatMapStringsSep "\n" (
        userId: inventory.users.${userId}.sshPubKey
      ) allowIn;
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

{
  lib,
  inventory,
  userid,
  ...
}:
let
  sshGraph = inventory.topology.ssh;
  # 所有允许连接到该用户的来源列表
  allowIn = sshGraph |> lib.filter ({ from, to }: to == userid) |> lib.map (entry: entry.from);
  # 所有该用户允许连接到的目标列表
  allowOut = sshGraph |> lib.filter ({ from, to }: from == userid) |> lib.map (entry: entry.to);
in
{
  options.openssh.authorizedKeys =
    with lib;
    mkOption {
      type = types.lines;
      description = "List of authorized SSH public keys.";
      default = "";
    };
  imports = allowOut |> lib.map (toUserId: inventory.users.${toUserId}.sshConfig);
  config =
    let
      authorizedKeysOfAllowIn = lib.concatMapStringsSep "\n" (
        userId: inventory.users.${userId}.sshPubKeys
      ) allowIn;
    in
    {
      home.file.".ssh/authorized_keys".text = lib.mKIf (
        authorizedKeysOfAllowIn != ""
      ) authorizedKeysOfAllowIn;
    };
}

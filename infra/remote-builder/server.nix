# 服务器端配置
{
  users.users.remote-builder = {
    isNormalUser = true;
    description = "Remote Nix Builder";
    createHome = true;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_ed25519.pub)
    ];
  };
  nix.settings.trusted-users = [
    "remote-builder"
  ];
}

{
  users.users.remote-builder = {
    isNormalUser = true;
    description = "Remote Nix Builder";
    createHome = true;
  };
  nix.settings.trusted-users = [
    "root"
    "remote-builder"
  ];
}

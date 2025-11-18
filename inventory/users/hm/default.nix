{
  "ashenye@desk00-u265kf-lan" = {
    mainModule = ./hm-module-entries + "/ashenye@desk00-u265kf-lan.nix";
    extraModules = [ ];
    userInfo = {
      description = "ashenye on desk00-u265kf-lan";
      role = "cat";
      tags = [
        "gaming"
      ];
      sshPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvnf1TDq7kpCwOMFK0Vn6x7zjMEiGGIVhknGN+kC3n0 ashenye@desk00-u265kf-lan";
    };
  };
  "ashenye@lap00-xiaoxin-mei" = {
    mainModule = ./hm-module-entries + "/ashenye@lap00-xiaoxin-mei.nix";
    extraModules = [ ];
    userInfo = {
      description = "ashenye on lap00-xiaoxin-mei";
      role = "cat";
      tags = [];
      sshPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCHoR+QLELtWTjo8EWiat8FNcyiAEQniZ6kkaOFCIlV ashenye@lap00-xiaoxin-mei";
    };
  };
  "ubuntu@zju-zhang" = {
    mainModule = ./hm-module-entries + "/ubuntu@zju-zhang.nix";
    extraModules = [ ];
    userInfo = {
      description = "ubuntu on zju-zhang";
      role = "zoo";
      tags = [
        "fox"
        "zju"
      ];
    };
  };
}

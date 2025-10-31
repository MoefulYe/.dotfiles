{
  "ashenye@desk00-u265kf-lan" = {
    mainModule = ./hm-module-entries + "/ashenye@desk00-u265kf-lan.nix";
    extraModules = [
      ../../../quirks/shared/unsafe-openssl.nix
      ../../../quirks/shared/unsafe-libxml2-2.13.8.nix
    ];
    userInfo = {
      description = "ashenye on desk00-u265kf-lan";
      tags = [
        "daily"
        "cat"
      ];
      sshPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvnf1TDq7kpCwOMFK0Vn6x7zjMEiGGIVhknGN+kC3n0 ashenye@desk00-u265kf-lan";
    };
  };
  "ashenye@lap00-xiaoxin-mei" = {
    mainModule = ./hm-module-entries + "/ashenye@lap00-xiaoxin-mei.nix";
    extraModules = [
      ../../../quirks/shared/unsafe-openssl.nix
      ../../../quirks/shared/unsafe-libxml2-2.13.8.nix
    ];
    userInfo = {
      description = "ashenye on lap00-xiaoxin-mei";
      tags = [
        "daily"
        "cat"
      ];
      sshPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCHoR+QLELtWTjo8EWiat8FNcyiAEQniZ6kkaOFCIlV ashenye@lap00-xiaoxin-mei";
    };
  };
}

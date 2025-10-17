{
  "ashenye@desk00-u265kf-lan" = {
    mainModule = ./hm-module-entries + "/ashenye@desk00-u265kf-lan.nix";
    extraModules = [
      ../../quirks/shared/unsafe-openssl.nix
      ../../quirks/shared/unsafe-libxml2-2.13.8.nix
    ];
    userInfo = {
      description = "ashenye on desk00-u265kf-lan";
      tags = [ ];
    };
  };
  "ashenye@lap00-xiaoxin-mei" = {
    mainModule = ./hm-module-entries + "/ashenye@lap00-xiaoxin-mei.nix";
    extraModules = [
      ../../quirks/shared/unsafe-openssl.nix
      ../../quirks/shared/unsafe-libxml2-2.13.8.nix
    ];
    userInfo = {
      description = "ashenye on lap00-xiaoxin-mei";
      tags = [ ];
    };
  };
}

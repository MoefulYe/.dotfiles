let
  # 我的主要邮箱
  myEmail = "luren145@gmail.com";
in
{
  "ashenye@desk00-u265kf-lan" = {
    mainModule = "./hm-module-entries/ashenye@desk00-u265kf-lan.nix";
    extraModules = [ ];
    userInfo = {
      description = "ashenye on desk00-u265kf-lan";
      tags = [ ];
      email = myEmail;
    };
  };
}

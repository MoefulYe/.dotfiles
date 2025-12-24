let
  mkHmConfigEntry = username: ./hm-module-entries + ("/" + username);
in
{
  "ashenye@desk00-u265kf-lan" = {
    description = "ashenye on desk00-u265kf-lan";
    role = "cat";
    tags = [
      "gaming"
      "daily"
    ];
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvnf1TDq7kpCwOMFK0Vn6x7zjMEiGGIVhknGN+kC3n0 ashenye@desk00-u265kf-lan";
    hmConfig = mkHmConfigEntry "ashenye@desk00-u265kf-lan.nix";
    sshConfig = ./ssh-configs + "/ashenye@desk00-u265kf-lan.nix";
  };
  "ashenye@lap00-xiaoxin-mei" = {
    description = "ashenye on lap00-xiaoxin-mei";
    role = "dog";
    tags = [ ];
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCHoR+QLELtWTjo8EWiat8FNcyiAEQniZ6kkaOFCIlV ashenye@lein";
    hmConfig = mkHmConfigEntry "ashenye@lap00-xiaoxin-mei.nix";
    sshConfig = ./ssh-configs + "/ashenye@lap00-xiaoxin-mei.nix";
  };
  "ashenye@lap01-macm4-mume" = {
    description = "ashenye on lap01-macm4-mume";
    role = "hermit";
    tags = [
      "daily"
    ];
    hmConfig = mkHmConfigEntry "ashenye@lap01-macm4-mume.nix";
    sshConfig = ./ssh-configs + "/ashenye@lap01-macm4-mume.nix";
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKl8IkGvU1g8lv/r+RtRVXXmtlW0XNac5zQrRgZ3RCij ashenye@lap01-macm4-mume";
  };
  "ubuntu@zju-zhang" = {
    username = "ubuntu";
    hostname = "sv";
    role = "fox";
    tags = [ "zju" ];
    hmConfig = mkHmConfigEntry "ubuntu@zju-zhang.nix";
    sshConfig = ./ssh-configs + "/ubuntu@zju-zhang.nix";
  };
  "yu@zju-yu-sg" = {
    username = "jiongchiyu";
    hostname = "XXF-GPU-00";
    role = "fox";
    tags = [ "zju" ];
    sshConfig = ./ssh-configs + "/yu@zju-yu-sg.nix";
  };
  "root@rutr00-k2p-zhuque" = {
    tags = [ "router" ];
    sshConfig = ./ssh-configs + "/root@rutr00-k2p-zhuque.nix";
  };
  "ashenye@rutr01-j4105-qingloong" = {
    description = "ashenye on rutr01-j4105-qingloong";
    role = "fox";
    tags = [ "router" ];
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0h/Sw/GdJy8/Z88HIFwDWrhLg00/iw/X3gsBPBfSDM ashenye@rutr01-j4105-qingloong";
    sshConfig = ./ssh-configs + "/ashenye@rutr01-j4105-qingloong.nix";
    hmConfig = mkHmConfigEntry "ashenye@rutr01-j4105-qingloong.nix";
  };
}

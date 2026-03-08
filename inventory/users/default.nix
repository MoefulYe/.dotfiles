{
  "ashenye@lan" = {
    role = "cat";
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvnf1TDq7kpCwOMFK0Vn6x7zjMEiGGIVhknGN+kC3n0 ashenye@desk00-u265kf-lan";
    hmConfig = ./home-manager/lan.nix;
    sshConfig = ./ssh-configs/lan.nix;
  };
  "ashenye@mume" = {
    role = "hermit";
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKl8IkGvU1g8lv/r+RtRVXXmtlW0XNac5zQrRgZ3RCij ashenye@lap01-macm4-mume";
    hmConfig = ./home-manager/mume.nix;
    sshConfig = ./ssh-configs/mume.nix;
  };
  "ubuntu@zhang.zju" = {
    username = "ubuntu";
    hostname = "sv";
    role = "fox";
    tags = [ "zju" ];
    hmConfig = ./home-manager/zhang.zju.nix;
    sshConfig = ./ssh-configs/zhang.zju.nix;
  };
  "yu@yu-sg.zju" = {
    username = "jiongchiyu";
    hostname = "XXF-GPU-00";
    role = "fox";
    tags = [ "zju" ];
    sshConfig = ./ssh-configs/yu-sg.zju.nix;
  };
  "zhao@zju-zhao" = {
    sshConfig = ./ssh-configs/zzm.zju.nix;
  };
  "root@zhuque" = {
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
  "ashenye@vps00-foxhk-citrus" = {
    description = "ashenye on vps00-foxhk-citrus";
    role = "dog";
    tags = [ "vps" ];
    sshConfig = ./ssh-configs + "/ashenye@vps00-foxhk-citrus.nix";
    hmConfig = mkHmConfigEntry "ashenye@vps00-foxhk-citrus.nix";
  };
  "ashenye@vps01-hawk-lemon" = {
    description = "ashenye on vps01-hawk-lemon";
    role = "dog";
    tags = [ "vps" ];
    sshConfig = ./ssh-configs + "/ashenye@vps01-hawk-lemon.nix";
    hmConfig = mkHmConfigEntry "ashenye@vps01-hawk-lemon.nix";
  };
}

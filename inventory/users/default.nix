_: {
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
  "ashenye@qingloong" = {
    role = "dog";
    sshConfig = ./ssh-configs/qingloong.nix;
  };
  "ashenye@citrus" = {
    role = "dog";
    sshConfig = ./ssh-configs/citrus.nix;
  };
  "ashenye@lemon" = {
    role = "dog";
    sshConfig = ./ssh-configs/lemon.nix;
  };
  "ashenye@yuzu" = {
    role = "dog";
    sshConfig = ./ssh-configs/lemon.nix;
  };
  "ubuntu@zhang.zju".sshConfig = ./ssh-configs/zhang.zju.nix;
  "yu@yu-sg.zju".sshConfig = ./ssh-configs/yu-sg.zju.nix;
  "zzm@zzm.zju".sshConfig = ./ssh-configs/zzm.zju.nix;
  "root@zhuque".sshConfig = ./ssh-configs/zhuque.nix;
}

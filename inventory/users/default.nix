let
  mkHmConfigEntry = username: ./hm-module-entries + ("/" + username);
in
{
  "ashenye@desk00-u265kf-lan" = {
    description = "ashenye on desk00-u265kf-lan";
    role = "cat";
    tags = [
      "gaming"
    ];
    sshPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvnf1TDq7kpCwOMFK0Vn6x7zjMEiGGIVhknGN+kC3n0 ashenye@desk00-u265kf-lan";
    hmConfig = mkHmConfigEntry "ashenye@desk00-u265kf-lan.nix";
  };
  "ashenye@lap00-xiaoxin-mei" = {
    description = "ashenye on lap00-xiaoxin-mei";
    role = "cat";
    tags = [ ];
    sshPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCHoR+QLELtWTjo8EWiat8FNcyiAEQniZ6kkaOFCIlV ashenye@lap00-xiaoxin-mei";
    hmConfig = mkHmConfigEntry "ashenye@lap00-xiaoxin-mei.nix";
  };
  "ubuntu@zju-zhang" = {
    username = "ubuntu";
    hostname = "sv";
    role = "fox";
    tags = [ "zju" ];
    hmConfig = mkHmConfigEntry "ubuntu@zju-zhang.nix";
    sshConfig = ./ssh-configs/zju-zhang.nix;
  };
  "yu@zju-yu-sg" = {
    username = "jiongchiyu";
    hostname = "XXF-GPU-00";
    role = "fox";
    tags = [ "zju" ];
    sshConfig = ./ssh-configs/zju-yu-sg.nix;
  };
}

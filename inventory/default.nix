{ lib, ... }:
<<<<<<< HEAD
{
  hosts = import ./hosts;
  users = import ./users;
  topology = import ./topology;
=======
rec {
  hosts = rec {
    # zju校内主机
    zju = import ./hosts/external/zju;
    # 内部的受自己管理的nixos主机
    nixos = import ./hosts/nixos;
    # 内部的受自己管理的非nixos主机
    non-nixos = import ./hosts/non-nixos;
    all = zju // nixos // non-nixos;
  };
  users = rec {
    # 内部的使用home-manager管理的用户
    hm = import ./users/hm;
    # 内部的非home-manager管理的用户
    non-hm = import ./users/non-hm;
    all = hm // non-hm;
  };
  zjuSshConfigs = zju |> lib.mapAttrs (name: props: props.sshConfig) |> lib.attrValues;
>>>>>>> ec25090 (x)
}

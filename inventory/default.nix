{ lib, ... }:
rec {
  hosts = import ./hosts;
  users = rec {
    # 内部的使用home-manager管理的用户
    hm = import ./users/hm;
    # 内部的非home-manager管理的用户
    non-hm = import ./users/non-hm;
    all = hm // non-hm;
  };
  zjuSshConfigs = hosts.zju |> lib.mapAttrs (name: props: props.hostInfo.sshConfig) |> lib.attrValues;
}

{
  # 外部的不受自己管理的主机
  externalHosts = import ./external-hosts;
  # 内部的受自己管理的nixos主机
  nixosHosts = import ./nixos-hosts;
  # 内部的受自己管理的非nixos主机
  nonNixosHosts = import ./non-nixos-hosts;
  # 使用home-manager管理的用户
  hmUsers = import ./hm-users;
}
